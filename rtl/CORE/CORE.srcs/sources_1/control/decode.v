`timescale 1ns / 1ps
`ifndef MISIRI_DECODE_V
`define MISIRI_DECODE_V

`include "../common/opcodes.v"
`include "../common/alu_ops.v"
`include "../common/imm_types.v"

module decode (
    input  wire [31:0] instr,

    output reg  [4:0]  rs1,
    output reg  [4:0]  rs2,
    output reg  [4:0]  rd,

    output reg  [3:0]  alu_op,
    output reg         alu_src_a_pc,
    output reg         alu_src_b_imm,

    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,

    output reg  [1:0]  wb_sel,
    output reg  [2:0]  branch_type,
    output reg  [2:0]  imm_type,
    
    // Señales para PC MUX
    output reg         is_jal,
    output reg         is_jalr
);

    // Campos básicos
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

        wb_sel      = 2'b00;   // ALU
        branch_type = 3'b000;  // NONE
        imm_type    = 3'b000;  // NONE
        is_jal      = 1'b0;
        is_jalr     = 1'b0;

        case (opcode)

            // R-type: ADD, SUB, SLT
            `OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_src_b_imm = 1'b0;
                imm_type = 3'b000; // IMM_NONE
                case ({funct7, funct3})
                    {7'b0000000,3'b000}: alu_op = `ALU_ADD; // ADD
                    {7'b0100000,3'b000}: alu_op = `ALU_SUB; // SUB
                    {7'b0000000,3'b010}: alu_op = `ALU_SLT; // SLT
                    default: alu_op = `ALU_NOP;
                endcase
            end

            // I-type: ADDI
            `OPCODE_ITYPE: begin
                reg_write     = 1'b1;
                alu_src_b_imm = 1'b1;
                alu_op        = `ALU_ADD;  // ADDI
                imm_type      = `IMM_I;
            end

            `OPCODE_LOAD: begin
                reg_write     = 1'b1;
                mem_read      = 1'b1;
                alu_src_b_imm = 1'b1;
                wb_sel        = 2'b01; // MEM
                alu_op        = `ALU_ADD; // dirección
                imm_type      = `IMM_I;
            end

            `OPCODE_STORE: begin
                mem_write     = 1'b1;
                alu_src_b_imm = 1'b1;
                alu_op        = `ALU_ADD; // dirección
                imm_type      = `IMM_S;
            end

            `OPCODE_BRANCH: begin
                alu_op      = `ALU_SUB;
                branch_type = funct3;
                imm_type    = `IMM_B;
            end

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

            default: begin
                alu_op = `ALU_NOP;
            end

        endcase
    end
endmodule

`endif
