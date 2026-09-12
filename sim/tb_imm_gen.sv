`timescale 1ns / 1ps

module tb_imm_gen;

    logic [31:0] inst;
    logic [31:0] imm;

    // Instantiate Device Under Test
    imm_gen dut (
        .inst(inst),
        .imm(imm)
    );

    initial begin
        $dumpfile("build/imm_gen.vcd");
        $dumpvars(0, tb_imm_gen);

        $display("--- Starting Immediate Generator Verification ---");

        // Test 1: I-type ADDI (addi x1, x0, -5) -> imm should be -5 (32'hFFFFFFF8 in 2's complement)
        // Machine code: 0xFFB00093
        inst = 32'hFFB00093; #10;
        assert(imm == -32'sd5) else $error("I-type negative immediate failed! Got: %h", imm);

        // Test 2: S-type SW (sw x2, 8(x1)) -> imm should be +8
        // Machine code: 0x0020A423
        inst = 32'h0020A423; #10;
        assert(imm == 32'd8) else $error("S-type immediate failed! Got: %d", imm);

        // Test 3: U-type LUI (lui x1, 0x12345) -> imm should be 32'h12345000
        // Machine code: 0x123450B7
        inst = 32'h123450B7; #10;
        assert(imm == 32'h12345000) else $error("U-type immediate failed! Got: %h", imm);

        $display("--- All Immediate Generator Tests Passed Successfully! ---");
        $finish;
    end

endmodule