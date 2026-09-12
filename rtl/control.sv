module control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       reg_write,
    output logic       alu_src,
    output logic       mem_read,
    output logic       mem_write,
    output logic       mem_to_reg,
    output logic       branch,
    output logic       jump,
    output logic [3:0] alu_ctrl
);

    always_comb begin
        // Default safe values (NOP / inactive)
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_ctrl   = 4'b0000;

        case (opcode)
            // R-Type: Register-Register operations
            7'b0110011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0; // ALU Input B comes from rs2
                mem_to_reg = 1'b0; // Write ALU result to rd

                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: alu_ctrl = 4'b0101;                         // SLL
                    3'b010: alu_ctrl = 4'b1000;                         // SLT
                    3'b011: alu_ctrl = 4'b1001;                         // SLTU
                    3'b100: alu_ctrl = 4'b0100;                         // XOR
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: alu_ctrl = 4'b0011;                         // OR
                    3'b111: alu_ctrl = 4'b0010;                         // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            // I-Type: Register-Immediate arithmetic
            7'b0010011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1; // ALU Input B comes from immediate
                mem_to_reg = 1'b0;

                case (funct3)
                    3'b000: alu_ctrl = 4'b0000;                         // ADDI
                    3'b001: alu_ctrl = 4'b0101;                         // SLLI
                    3'b010: alu_ctrl = 4'b1000;                         // SLTI
                    3'b011: alu_ctrl = 4'b1001;                         // SLTIU
                    3'b100: alu_ctrl = 4'b0100;                         // XORI
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b0111 : 4'b0110; // SRAI : SRLI
                    3'b110: alu_ctrl = 4'b0011;                         // ORI
                    3'b111: alu_ctrl = 4'b0010;                         // ANDI
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            // Load: lw
            7'b0000011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1; // Calculate address: rs1 + imm
                mem_read   = 1'b1; // Read from RAM
                mem_to_reg = 1'b1; // Write RAM output to rd
                alu_ctrl   = 4'b0000; // ADD for address computation
            end

            // Store: sw
            7'b0100011: begin
                reg_write  = 1'b0;
                alu_src    = 1'b1; // Calculate address: rs1 + imm
                mem_write  = 1'b1; // Write to RAM
                alu_ctrl   = 4'b0000; // ADD for address computation
            end

            // Branch: beq, bne, blt, bge
            7'b1100011: begin
                reg_write  = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b1;
                alu_ctrl   = 4'b0001; // SUB to compare rs1 and rs2
            end

            // Jump: jal
            7'b1101111: begin
                reg_write  = 1'b1; // Save return address (PC+4) to rd
                jump       = 1'b1;
            end

            default: begin
                // Retains all default 0 values set at start of always_comb
            end
        endcase
    end

endmodule