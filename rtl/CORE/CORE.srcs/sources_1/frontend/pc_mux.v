`timescale 1ns / 1ps
`ifndef MISIRI_PC_MUX_V
`define MISIRI_PC_MUX_V

// -----------------------------------------------------------------------------
// pc_mux.v
// Proyecto: MISIRI Core
// Descripción:
//  Lógica combinacional para selección del siguiente PC.
//  No contiene estado.
// -----------------------------------------------------------------------------

module pc_mux (
    input  wire [31:0] pc_curr,

    // Inmediatos
    input  wire [31:0] imm_B,
    input  wire [31:0] imm_J,
    input  wire [31:0] imm_I,

    // Registro fuente
    input  wire [31:0] rs1_val,

    // Control
    input  wire        branch_taken,
    input  wire        is_jal,
    input  wire        is_jalr,

    output reg  [31:0] pc_next
);

    always @(*) begin
        // Prioridad RISC-V
        if (is_jalr) begin
            // JALR: (rs1 + imm) & ~1
            pc_next = (rs1_val + imm_I) & 32'hFFFFFFFE;
        end
        else if (is_jal) begin
            // JAL: PC + inmediato J
            pc_next = pc_curr + imm_J;
        end
        else if (branch_taken) begin
            // Branch tomado: PC + inmediato B
            pc_next = pc_curr + imm_B;
        end
        else begin
            // Ejecución secuencial
            pc_next = pc_curr + 32'd4;
        end
    end

endmodule

`endif
