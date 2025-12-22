`timescale 1ns / 1ps
`ifndef MISIRI_IMM_TYPES_V
`define MISIRI_IMM_TYPES_V

// -------------------------------------------------------------
// Archivo: imm_types.v
// Proyecto: MISIRI Core
// Descripción:
//   Definiciones de los tipos de inmediato usados por el decode
//   y el generador de inmediatos (imm_gen).
// -------------------------------------------------------------

// Codificación interna para imm_type (3 bits)
`define IMM_NONE 3'b000
`define IMM_I    3'b001
`define IMM_S    3'b010
`define IMM_B    3'b011
`define IMM_J    3'b100
`define IMM_U    3'b101

`endif
