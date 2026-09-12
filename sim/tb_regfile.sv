`timescale 1ns / 1ps

module tb_regfile;

    logic        clk;
    logic        rst_n;
    logic        reg_write;
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [4:0]  rd_addr;
    logic [31:0] rd_data;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // Instantiate Device Under Test
    regfile dut (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Generate 10ns clock period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/regfile.vcd");
        $dumpvars(0, tb_regfile);

        // Initialize signals
        clk = 0;
        rst_n = 0;
        reg_write = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        rd_data = 0;

        $display("--- Starting RegFile Verification ---");

        // Step 1: Release Reset
        #15 rst_n = 1;

        // Step 2: Write 32'hDEADBEEF into Register x1
        @(posedge clk);
        rd_addr = 5'd1;
        rd_data = 32'hDEADBEEF;
        reg_write = 1;

        // Step 3: Write 32'hCAFE1234 into Register x2
        @(posedge clk);
        rd_addr = 5'd2;
        rd_data = 32'hCAFE1234;
        reg_write = 1;

        // Step 4: Stop writing and read both x1 and x2 simultaneously
        @(posedge clk);
        reg_write = 0;
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        #1; // Wait 1ns for combinational read to settle
        assert(rs1_data == 32'hDEADBEEF) else $error("Read x1 failed! Value: %h", rs1_data);
        assert(rs2_data == 32'hCAFE1234) else $error("Read x2 failed! Value: %h", rs2_data);

        // Step 5: Test x0 Zero Rule (Try writing 32'hFFFFFFFF to x0)
        @(posedge clk);
        rd_addr = 5'd0;
        rd_data = 32'hFFFFFFFF;
        reg_write = 1;

        @(posedge clk);
        reg_write = 0;
        rs1_addr = 5'd0;
        #1;
        assert(rs1_data == 32'd0) else $error("x0 was overwritten! Value: %h", rs1_data);

        $display("--- All RegFile Tests Passed Successfully! ---");
        $finish;
    end

endmodule