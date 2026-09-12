`timescale 1ns / 1ps

module tb_core;

    logic        clk;
    logic        rst_n;
    logic [31:0] imem_addr;
    logic [31:0] imem_rdata;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic        dmem_wen;
    logic [31:0] dmem_rdata;

    // Instantiate the CPU Core
    core dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_wen   (dmem_wen),
        .dmem_rdata (dmem_rdata)
    );

    // -------------------------------------------------------------
    // Simulated Unified Memory (256 Words = 1 KB)
    // -------------------------------------------------------------
    logic [31:0] memory [0:255];

    // Word-aligned access: divide byte address by 4 (>> 2)
    assign imem_rdata = memory[imem_addr >> 2];
    assign dmem_rdata = memory[dmem_addr >> 2];

    // Synchronous memory write
    always_ff @(posedge clk) begin
        if (dmem_wen) begin
            memory[dmem_addr >> 2] <= dmem_wdata;
        end
    end

    // 10ns Clock Period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/core.vcd");
        $dumpvars(0, tb_core);

        // ---------------------------------------------------------
        // Sample RISC-V Machine Code Program:
        // ---------------------------------------------------------
        // 1. addi x1, x0, 10      (x1 = 10)
        memory[0] = 32'h00a00093;
        // 2. addi x2, x0, 20      (x2 = 20)
        memory[1] = 32'h01400113;
        // 3. add  x3, x1, x2      (x3 = 10 + 20 = 30)
        memory[2] = 32'h002081b3;
        // 4. sw   x3, 0(x0)       (Store 30 to memory[0])
        memory[3] = 32'h00302023;
        // 5. lw   x4, 0(x0)       (Load 30 from memory[0] into x4)
        memory[4] = 32'h00002203;

        // Fill remaining memory with 0s
        for (int i = 5; i < 256; i++) memory[i] = 32'd0;

        clk = 0;
        rst_n = 0;

        $display("--- Starting RISC-V Core Program Simulation ---");

        // Release reset after 15ns
        #15 rst_n = 1;

        // Run for 6 clock cycles to complete all 5 instructions
        repeat (6) @(posedge clk);
        #1;

        // Verify register contents
        assert(dut.rf.registers[1] == 32'd10) else $error("Assertion Failed: x1 != 10 (Got: %0d)", dut.rf.registers[1]);
        assert(dut.rf.registers[2] == 32'd20) else $error("Assertion Failed: x2 != 20 (Got: %0d)", dut.rf.registers[2]);
        assert(dut.rf.registers[3] == 32'd30) else $error("Assertion Failed: x3 != 30 (Got: %0d)", dut.rf.registers[3]);
        assert(dut.rf.registers[4] == 32'd30) else $error("Assertion Failed: x4 != 30 (Got: %0d)", dut.rf.registers[4]);

        // Verify RAM write
        assert(memory[0] == 32'd30) else $error("Assertion Failed: RAM[0] != 30 (Got: %0d)", memory[0]);

        $display("--- SUCCESS: All Instructions Executed & Core Verified! ---");
        $finish;
    end

endmodule
