`timescale 1ns / 1ps

module tb_alu;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_ctrl;
    logic [31:0] result;
    logic        zero;

    // Instantiate Device Under Test (DUT)
    alu dut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        // Setup waveform dump file
        $dumpfile("build/alu.vcd");
        $dumpvars(0, tb_alu);

        $display("--- Starting ALU Verification ---");

        // Test 1: ADD (15 + 27 = 42)
        a = 32'd15; b = 32'd27; alu_ctrl = 4'b0000; #10;
        assert(result == 32'd42) else $error("ADD failed! Result: %d", result);

        // Test 2: SUB (50 - 20 = 30)
        a = 32'd50; b = 32'd20; alu_ctrl = 4'b0001; #10;
        assert(result == 32'd30 && zero == 0) else $error("SUB failed!");

        // Test 3: SUB zero flag check (10 - 10 = 0)
        a = 32'd10; b = 32'd10; alu_ctrl = 4'b0001; #10;
        assert(result == 32'd0 && zero == 1) else $error("Zero flag failed!");

        // Test 4: SRA (Arithmetic Shift Right: preserve sign bit)
        a = -32'd16; b = 32'd2; alu_ctrl = 4'b0111; #10;
        assert(result == -32'd4) else $error("SRA failed! Result: %d", result);

        // Test 5: SLT (Signed comparison: -5 < 3 should be 1)
        a = -32'd5; b = 32'd3; alu_ctrl = 4'b1000; #10;
        assert(result == 32'd1) else $error("SLT failed!");

        $display("--- All ALU Tests Passed Successfully! ---");
        $finish;
    end

endmodule