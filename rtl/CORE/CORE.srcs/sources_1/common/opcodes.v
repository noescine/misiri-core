// -------------------------------------------------------------
// Archivo: opcodes.v
// Proyecto: MISIRI Core
// Descripción:
//   Definiciones de opcodes RV32I base
//   Usado por el módulo decode y control
// -------------------------------------------------------------

`ifndef MISIRI_OPCODES_V
`define MISIRI_OPCODES_V

// Opcodes principales (instr[6:0])

`define OPCODE_RTYPE   7'b0110011  // ADD, SUB, AND, OR, XOR, etc
`define OPCODE_ITYPE   7'b0010011  // ADDI, ANDI, ORI
`define OPCODE_LOAD    7'b0000011  // LW
`define OPCODE_STORE   7'b0100011  // SW
`define OPCODE_BRANCH  7'b1100011  // BEQ, BNE, BLT, BGE
`define OPCODE_JAL     7'b1101111  // JAL
`define OPCODE_JALR    7'b1100111  // JALR (v1 o v2)
`define OPCODE_LUI     7'b0110111  // LUI (v2)
`define OPCODE_AUIPC   7'b0010111  // AUIPC (v2)

`endif
