// -------------------------------------------------------------
// Archivo: alu_ops.v
// Proyecto: MISIRI Core
// Descripción:
//   Definiciones de operaciones soportadas por la ALU
// -------------------------------------------------------------

`ifndef MISIRI_ALU_OPS_V
`define MISIRI_ALU_OPS_V

// Operaciones básicas (codificación interna)

`define ALU_ADD   4'd0
`define ALU_SUB   4'd1
`define ALU_AND   4'd2
`define ALU_OR    4'd3
`define ALU_XOR   4'd4
`define ALU_SLL   4'd5
`define ALU_SRL   4'd6
`define ALU_SRA   4'd7
`define ALU_SLT   4'd8
`define ALU_SLTU  4'd9

// Reservado para extensiones custom MISIRI
`define ALU_CUSTOM0 4'd12
`define ALU_CUSTOM1 4'd13
`define ALU_CUSTOM2 4'd14
`define ALU_NOP     4'd15

`endif
