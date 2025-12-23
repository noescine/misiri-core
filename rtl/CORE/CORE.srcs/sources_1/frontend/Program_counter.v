`timescale 1ns / 1ps
`ifndef MISIRI_PC_REG_V
`define MISIRI_PC_REG_V

// -----------------------------------------------------------------------------
// pc_reg.v
// Proyecto: MISIRI Core
// Descripción:
//  Registro del Program Counter.
//  NO decide saltos.
//  NO conoce instrucciones.
// -----------------------------------------------------------------------------

module pc_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_en,
    input  wire [31:0] pc_next,

    output reg  [31:0] pc
);

    always @(posedge clk) begin
        if (rst)
            pc <= 32'd0;
        else if (pc_en)
            pc <= pc_next;
    end

endmodule

`endif