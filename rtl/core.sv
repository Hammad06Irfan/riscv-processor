module core (
    input  logic        clk,
    input  logic        rst_n,

    // Instruction Memory Interface
    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,

    // Data Memory Interface
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    output logic        dmem_wen,
    input  logic [31:0] dmem_rdata
);

    // -------------------------------------------------------------
    // Internal Signals
    // -------------------------------------------------------------
    logic [31:0] pc, pc_next, pc_plus_4, branch_target;
    logic [31:0] rs1_data, rs2_data, rd_data;
    logic [31:0] imm;
    logic [31:0] alu_b, alu_result;
    logic        zero;

    // Control signals
    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;
    logic       jump;
    logic [3:0] alu_ctrl;

    // -------------------------------------------------------------
    // 1. Program Counter (PC) Logic
    // -------------------------------------------------------------
    assign pc_plus_4     = pc + 32'd4;
    assign branch_target = pc + imm;
    assign imem_addr     = pc;

    always_comb begin
        if (jump || (branch && zero)) begin
            pc_next = branch_target;
        end else begin
            pc_next = pc_plus_4;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'd0;
        end else begin
            pc <= pc_next;
        end
    end

    // -------------------------------------------------------------
    // 2. Control Unit
    // -------------------------------------------------------------
    control ctrl_unit (
        .opcode     (imem_rdata[6:0]),
        .funct3     (imem_rdata[14:12]),
        .funct7     (imem_rdata[31:25]),
        .reg_write  (reg_write),
        .alu_src    (alu_src),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .jump       (jump),
        .alu_ctrl   (alu_ctrl)
    );

    // -------------------------------------------------------------
    // 3. Register File
    // -------------------------------------------------------------
    regfile rf (
        .clk        (clk),
        .rst_n      (rst_n),
        .reg_write  (reg_write),
        .rs1_addr   (imem_rdata[19:15]),
        .rs2_addr   (imem_rdata[24:20]),
        .rd_addr    (imem_rdata[11:7]),
        .rd_data    (rd_data),
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data)
    );

    // -------------------------------------------------------------
    // 4. Immediate Generator
    // -------------------------------------------------------------
    imm_gen ig (
        .inst       (imem_rdata),
        .imm        (imm)
    );

    // -------------------------------------------------------------
    // 5. ALU & Operand Multiplexer
    // -------------------------------------------------------------
    assign alu_b = (alu_src) ? imm : rs2_data;

    alu alu_unit (
        .a          (rs1_data),
        .b          (alu_b),
        .alu_ctrl   (alu_ctrl),
        .result     (alu_result),
        .zero       (zero)
    );

    // -------------------------------------------------------------
    // 6. Data Memory & Writeback Multiplexer
    // -------------------------------------------------------------
    assign dmem_addr  = alu_result;
    assign dmem_wdata = rs2_data;
    assign dmem_wen   = mem_write;

    always_comb begin
        if (jump) begin
            rd_data = pc_plus_4;   // JAL saves return address
        end else if (mem_to_reg) begin
            rd_data = dmem_rdata;  // Load instruction (LW)
        end else begin
            rd_data = alu_result;  // Normal arithmetic / logic
        end
    end

endmodule