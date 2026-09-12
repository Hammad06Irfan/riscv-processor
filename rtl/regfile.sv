module regfile (
    input  logic        clk,
    input  logic        rst_n,      // Active-low asynchronous reset
    input  logic        reg_write,  // Write enable flag (from control unit)
    input  logic [4:0]  rs1_addr,   // Source register 1 address (0-31)
    input  logic [4:0]  rs2_addr,   // Source register 2 address (0-31)
    input  logic [4:0]  rd_addr,    // Destination register address (0-31)
    input  logic [31:0] rd_data,    // Data to write into rd
    output logic [31:0] rs1_data,   // Read output for rs1
    output logic [31:0] rs2_data    // Read output for rs2
);

    // 32 registers, each 32 bits wide
    logic [31:0] registers [31:0];

    // Asynchronous / Combinational Read Ports
    // x0 is permanently wired to 0
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : registers[rs2_addr];

    // Synchronous Write Port on Rising Clock Edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'd0;
            end
        end else if (reg_write && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule