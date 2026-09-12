`timescale 1ns / 1ps

module tb_control;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;
    logic       jump;
    logic [3:0] alu_ctrl;

    // Instantiate Device Under Test
    control dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .alu_ctrl(alu_ctrl)
    );

    initial begin
        $dumpfile("build/control.vcd");
        $dumpvars(0, tb_control);

        $display("--- Starting Control Unit Verification ---");

        // Test 1: R-Type ADD (add rd, rs1, rs2)
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        assert(reg_write == 1 && alu_src == 0 && alu_ctrl == 4'b0000) 
            else $error("R-Type ADD control failed!");

        // Test 2: R-Type SUB (sub rd, rs1, rs2) -> funct7 bit 5 is 1
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000; #10;
        assert(reg_write == 1 && alu_src == 0 && alu_ctrl == 4'b0001) 
            else $error("R-Type SUB control failed!");

        // Test 3: I-Type ADDI (addi rd, rs1, imm)
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        assert(reg_write == 1 && alu_src == 1 && alu_ctrl == 4'b0000) 
            else $error("I-Type ADDI control failed!");

        // Test 4: Load Word (lw rd, imm(rs1))
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        assert(reg_write == 1 && mem_read == 1 && mem_to_reg == 1 && alu_src == 1) 
            else $error("LW control failed!");

        // Test 5: Store Word (sw rs2, imm(rs1))
        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        assert(reg_write == 0 && mem_write == 1 && alu_src == 1) 
            else $error("SW control failed!");

        $display("--- All Control Unit Tests Passed Successfully! ---");
        $finish;
    end

endmodule