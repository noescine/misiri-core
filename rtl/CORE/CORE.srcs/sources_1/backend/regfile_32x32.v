`timescale 1ns / 1ps
`ifndef MISIRI_REGFILE_32X32_V
`define MISIRI_REGFILE_32X32_V

// -----------------------------------------------------------------------------
// regfile_32x32.v
// Banco de registros RISC-V 32 x 32
// - Escritura síncrona (posedge clk)
// - Lecturas combinacionales
// - x0 forzado a 0 (no writable)
// - Reset síncrono opcional
// - Inicialización para simulación
// -----------------------------------------------------------------------------

module regfile_32x32 (
    input  wire        clk,
    input  wire        rst,          // si no quieres reset, conéctalo a 0
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
    // NOTA: profundidad pequeña -> puede mapearse a LUTs o BRAM según implementación
    reg [31:0] regs [31:0];

    integer i;
    // Reset / write synchronous
    always @(posedge clk) begin
        if (rst) begin
            // sincronously clear (optional)
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'd0;
        end else begin
            // Protección: nunca escribir en x0
            if (write_en && (rd_addr != 5'd0)) begin
                regs[rd_addr] <= rd_data;
            end
            // Blindaje: forzar x0 a 0 siempre (por si el sintetizador hizo algo raro)
            regs[0] <= 32'd0;
        end
    end

    // Lecturas combinacionales (x0 => 0)
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];

    // Inicialización para simulación (por si no aplicas reset en testbench)
    initial begin
        regs[0] = 32'd0;
        for (i = 1; i < 32; i = i + 1) regs[i] = 32'd0;
    end

endmodule

`endif

