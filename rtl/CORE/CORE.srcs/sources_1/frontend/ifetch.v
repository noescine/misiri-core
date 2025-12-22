`timescale 1ns / 1ps
`ifndef MISIRI_IFETCH_V
`define MISIRI_IFETCH_V

// -----------------------------------------------------------------------------
// ifetch.v
// Proyecto: MISIRI Core
// Descripción:
//  Unidad de Instruction Fetch.
//  - Lee instrucción desde IMEM usando PC
//  - Entrega instrucción alineada a decode
// -----------------------------------------------------------------------------

module ifetch (
    input  wire        clk,
    input  wire        rst,

    // PC actual
    input  wire [31:0] pc,

    // Interfaz a memoria de instrucciones
    output wire [31:0] imem_addr,
    input  wire [31:0] imem_rdata,

    // Salida hacia decode
    output reg  [31:0] instr,
    output reg         instr_valid
);

    // Dirección de instrucción = PC
    assign imem_addr = pc;

    always @(posedge clk) begin
        if (rst) begin
            instr       <= 32'd0;
            instr_valid <= 1'b0;
        end
        else begin
            instr       <= imem_rdata;
            instr_valid <= 1'b1;
        end
    end

endmodule

`endif
