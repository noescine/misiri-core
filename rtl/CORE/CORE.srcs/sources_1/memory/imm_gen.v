`timescale 1ns / 1ps
`ifndef MISIRI_IMM_GEN_V
`define MISIRI_IMM_GEN_V

// -------------------------------------------------------------
// Archivo: imm_gen.v
// Proyecto: MISIRI Core
// Ubicación sugerida: rtl/control/imm_gen.v
// Dependencias: rtl/common/imm_types.v
// Descripción:
//   Generador de inmediatos RV32I para MISIRI.
//   Produce imm_ext[31:0] apropiadamente sign-extendido y
//   con los desplazamientos requeridos (B/J incluyen LSB=0).
// -------------------------------------------------------------

`include "../common/imm_types.v"

module imm_gen (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_type,    // Usa los defines de imm_types.v
    output reg  [31:0] imm_ext
);

    // Campos usados
    wire i_sign = instr[31];
    wire b_sign = instr[31];
    wire j_sign = instr[31];
    wire s_sign = instr[31];

    always @(*) begin
        // default
        imm_ext = 32'b0;

        case (imm_type)
            `IMM_I: begin
                // I-type immediate: instr[31:20] sign-extended
                imm_ext = {{20{instr[31]}}, instr[31:20]};
            end

            `IMM_S: begin
                // S-type immediate: instr[31:25] <<5  | instr[11:7]
                // imm[11:0] = instr[31:25], instr[11:7]
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            `IMM_B: begin
                // B-type immediate: imm[12|10:5|4:1|11|0] from bits
                // imm[12] = instr[31]
                // imm[11] = instr[7]
                // imm[10:5] = instr[30:25]
                // imm[4:1] = instr[11:8]
                // imm[0] = 0
                imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                // Result: sign-extended 13-bit immediate shifted (LSB=0)
            end

            `IMM_J: begin
                // J-type immediate (JAL): imm[20|10:1|11|19:12|0]
                // imm[20] = instr[31]
                // imm[19:12] = instr[19:12]
                // imm[11] = instr[20]
                // imm[10:1] = instr[30:21]
                // imm[0] = 0
                imm_ext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                // Result: sign-extended 21-bit immediate shifted (LSB=0)
            end

            `IMM_U: begin
                // U-type immediate (LUI/AUIPC): imm[31:12] << 12
                imm_ext = {instr[31:12], 12'b0};
            end

            default: begin
                // IMM_NONE or unknown
                imm_ext = 32'b0;
            end
        endcase
    end

endmodule

`endif
