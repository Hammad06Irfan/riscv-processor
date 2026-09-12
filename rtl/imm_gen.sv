module imm_gen (
    input  logic [31:0] inst,
    output logic [31:0] imm
);

    // Opcode is always located in bits [6:0]
    logic [6:0] opcode;
    assign opcode = inst[6:0];

    always_comb begin
        case (opcode)
            // I-type: addi, andi, ori, xori, slti, sltiu, slli, srli, srai, lw, jalr
            7'b0010011, // OP-IMM
            7'b0000011, // LOAD
            7'b1100111: // JALR
                imm = {{20{inst[31]}}, inst[31:20]};

            // S-type: sw, sh, sb (Store instructions)
            7'b0100011: 
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            // B-type: beq, bne, blt, bge, bltu, bgeu (Branch instructions)
            7'b1100011: 
                imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};

            // U-type: lui, auipc (Upper Immediate)
            7'b0110111, // LUI
            7'b0010111: // AUIPC
                imm = {inst[31:12], 12'b0};

            // J-type: jal (Jump and Link)
            7'b1101111: 
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

            default: 
                imm = 32'd0;
        endcase
    end

endmodule