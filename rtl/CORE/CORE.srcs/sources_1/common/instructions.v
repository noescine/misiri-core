// -------------------------------------------------------------
// Archivo: instructions.v
// Proyecto: MISIRI Core
// Descripción:
//   Conjunto de instrucciones RISC-V RV32I base
//   Incluye opcodes y codificación ALU interna
// -------------------------------------------------------------

`ifndef MISIRI_INSTRUCTIONS_V
`define MISIRI_INSTRUCTIONS_V

// ----------------------------
// Opcodes (instr[6:0])
// ----------------------------
`define OPCODE_RTYPE   7'b0110011  // ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
`define OPCODE_ITYPE   7'b0010011  // ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
`define OPCODE_LOAD    7'b0000011  // LB, LH, LW, LBU, LHU
`define OPCODE_STORE   7'b0100011  // SB, SH, SW
`define OPCODE_BRANCH  7'b1100011  // BEQ, BNE, BLT, BGE, BLTU, BGEU
`define OPCODE_JAL     7'b1101111  // JAL
`define OPCODE_JALR    7'b1100111  // JALR
`define OPCODE_LUI     7'b0110111  // LUI
`define OPCODE_AUIPC   7'b0010111  // AUIPC

// ----------------------------
// ALU internal operations
// ----------------------------
`define ALU_ADD    4'd0
`define ALU_SUB    4'd1
`define ALU_AND    4'd2
`define ALU_OR     4'd3
`define ALU_XOR    4'd4
`define ALU_SLL    4'd5
`define ALU_SRL    4'd6
`define ALU_SRA    4'd7
`define ALU_SLT    4'd8
`define ALU_SLTU   4'd9
`define ALU_NOP    4'd15

// Reservado para extensiones custom
`define ALU_CUSTOM0 4'd12
`define ALU_CUSTOM1 4'd13
`define ALU_CUSTOM2 4'd14

`endif
