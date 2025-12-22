`timescale 1ns / 1ps
`ifndef MISIRI_REGFILE_32X32_V
`define MISIRI_REGFILE_32X32_V

// -----------------------------------------------------------------------------
// regfile_32x32.v
// Banco de registros RISC-V compatible (32x32)
// - 2 puertos de lectura combinacionales (rs1, rs2)
// - 1 puerto de escritura síncrono (rd, write_enable) en posedge clk
// - x0 hardwired a 0
// - reset opcional (sincronico) que pone registros a 0 (excepto x0 siempre 0)
// -----------------------------------------------------------------------------


module regfile_32x32 (
    input  wire        clk,
    input  wire        rst,          // opcional: si no quieres reset, conéctalo a 0
    // read ports
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    // write port
    input  wire        write_en,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data
);

    // Memoria interna: 32 registros de 32 bits
    reg [31:0] regs [31:0];

    integer i;
    // Reset synchronous: opcional. Mantener x0 = 0 siempre.
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
        end else begin
            if (write_en && (rd_addr != 5'd0)) begin
                regs[rd_addr] <= rd_data;
            end
            // note: x0 remains as regs[0] (zero) if reset asserted or never written
        end
    end

    // Lecturas combinacionales (comportamiento típico de regfile)
    // rs1_data = (rs1_addr == 0) ? 0 : regs[rs1_addr];  // para garantizar x0 = 0
    assign rs1_data = (rs1_addr == 5'd0) ? 32'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'b0 : regs[rs2_addr];

    // Inicializar registro 0 a 0 por si simulador no aplica reset al inicio
    initial begin
        regs[0] = 32'b0;
        for (i = 1; i < 32; i = i + 1) regs[i] = 32'b0;
    end

endmodule

`endif
