// -------------------------------------------------------------
// Archivo: decode.v
// Proyecto: MISIRI Core
// Descripción:
//   Decodificador completo para RV32I
// -------------------------------------------------------------
`timescale 1ns / 1ps
`ifndef MISIRI_DECODE_V
`define MISIRI_DECODE_V

`include "../common/instructions.v"
`include "../common/imm_types.v"

module decode (
    input  wire [31:0] instr,

    output reg  [4:0] rs1,
    output reg  [4:0] rs2,
    output reg  [4:0] rd,

    output reg  [3:0] alu_op,
    output reg        alu_src_a_pc,
    output reg        alu_src_b_imm,

    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg  [1:0] mem_size, // 00=byte,01=halfword,10=word

    output reg  [1:0] wb_sel,
    output reg  [2:0] branch_type,
    output reg  [2:0] imm_type,

    output reg        is_jal,
    output reg        is_jalr
);

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    always @(*) begin
        // Valores por defecto
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd  = instr[11:7];

        alu_op        = `ALU_ADD;
        alu_src_a_pc  = 1'b0;
        alu_src_b_imm = 1'b0;

        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_size  = 2'b10; // word por defecto

        wb_sel      = 2'b00; // ALU
        branch_type = 3'b000;
        imm_type    = 3'b000;
        is_jal      = 1'b0;
        is_jalr     = 1'b0;

        case (opcode)

            // ----------------
            // R-type
            // ----------------
            `OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_src_b_imm = 1'b0;
                imm_type = `IMM_NONE;
                case ({funct7, funct3})
                    {7'b0000000,3'b000}: alu_op = `ALU_ADD;
                    {7'b0100000,3'b000}: alu_op = `ALU_SUB;
                    {7'b0000000,3'b111}: alu_op = `ALU_AND;
                    {7'b0000000,3'b110}: alu_op = `ALU_OR;
                    {7'b0000000,3'b100}: alu_op = `ALU_XOR;
                    {7'b0000000,3'b001}: alu_op = `ALU_SLL;
                    {7'b0000000,3'b101}: alu_op = `ALU_SRL;
                    {7'b0100000,3'b101}: alu_op = `ALU_SRA;
                    {7'b0000000,3'b010}: alu_op = `ALU_SLT;
                    {7'b0000000,3'b011}: alu_op = `ALU_SLTU;
                    default: alu_op = `ALU_NOP;
                endcase
            end

            // ----------------
            // I-type ALU
            // ----------------
            `OPCODE_ITYPE: begin
                reg_write     = 1'b1;
                alu_src_b_imm = 1'b1;
                imm_type      = `IMM_I;
                case(funct3)
                    3'b000: alu_op = `ALU_ADD; // ADDI
                    3'b010: alu_op = `ALU_SLT; // SLTI
                    3'b011: alu_op = `ALU_SLTU;// SLTIU
                    3'b100: alu_op = `ALU_XOR; // XORI
                    3'b110: alu_op = `ALU_OR;  // ORI
                    3'b111: alu_op = `ALU_AND; // ANDI
                    3'b001: alu_op = `ALU_SLL; // SLLI
                    3'b101: alu_op = funct7[5] ? `ALU_SRA : `ALU_SRL; // SRLI/SRAI
                endcase
            end

            // ----------------
            // Load
            // ----------------
            `OPCODE_LOAD: begin
                reg_write     = 1'b1;
                mem_read      = 1'b1;
                alu_src_b_imm = 1'b1;
                wb_sel        = 2'b01; // MEM
                alu_op        = `ALU_ADD; // dirección
                imm_type      = `IMM_I;
                case(funct3)
                    3'b000: mem_size = 2'b00; // LB
                    3'b001: mem_size = 2'b01; // LH
                    3'b010: mem_size = 2'b10; // LW
                    3'b100: mem_size = 2'b00; // LBU
                    3'b101: mem_size = 2'b01; // LHU
                endcase
            end

            // ----------------
            // Store
            // ----------------
            `OPCODE_STORE: begin
                mem_write     = 1'b1;
                alu_src_b_imm = 1'b1;
                alu_op        = `ALU_ADD;
                imm_type      = `IMM_S;
                case(funct3)
                    3'b000: mem_size = 2'b00; // SB
                    3'b001: mem_size = 2'b01; // SH
                    3'b010: mem_size = 2'b10; // SW
                endcase
            end

            // ----------------
            // Branch
            // ----------------
            `OPCODE_BRANCH: begin
                alu_op      = `ALU_SUB;
                branch_type = funct3;
                imm_type    = `IMM_B;
            end

            // ----------------
            // JAL / JALR
            // ----------------
            `OPCODE_JAL: begin
                reg_write     = 1'b1;
                alu_src_a_pc  = 1'b1;
                alu_src_b_imm = 1'b1;
                wb_sel        = 2'b10; // PC+4
                imm_type      = `IMM_J;
                is_jal        = 1'b1;
            end

            `OPCODE_JALR: begin
                reg_write     = 1'b1;
                alu_src_a_pc  = 1'b1;
                alu_src_b_imm = 1'b1;
                wb_sel        = 2'b10;
                imm_type      = `IMM_I;
                is_jalr       = 1'b1;
            end

            // ----------------
            // LUI / AUIPC
            // ----------------
            `OPCODE_LUI: begin
                reg_write     = 1'b1;
                alu_src_b_imm = 1'b1;
                alu_op        = `ALU_ADD;
                wb_sel        = 2'b00;
                imm_type      = `IMM_U;
            end

            `OPCODE_AUIPC: begin
                reg_write     = 1'b1;
                alu_src_a_pc  = 1'b1;
                alu_src_b_imm = 1'b1;
                alu_op        = `ALU_ADD;
                wb_sel        = 2'b00;
                imm_type      = `IMM_U;
            end

            default: begin
                alu_op = `ALU_NOP;
            end

        endcase
    end

endmodule
`endif
