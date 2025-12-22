`timescale 1ns / 1ps
`ifndef MISIRI_BRANCH_UNIT_V
`define MISIRI_BRANCH_UNIT_V

// -----------------------------------------------------------------------------
// branch_unit.v
// Proyecto: MISIRI Core
// Descripción:
//  Decide si un branch RV32I es tomado o no.
//  Usa flags provenientes de la ALU.
// -----------------------------------------------------------------------------

module branch_unit (
    input  wire [2:0] branch_type,
    input  wire       flag_zero,
    input  wire       flag_neg,
    input  wire       flag_carry,
    output reg        branch_taken
);

    always @(*) begin
        case (branch_type)
            3'b000: branch_taken = flag_zero;             // BEQ
            3'b001: branch_taken = ~flag_zero;            // BNE
            3'b100: branch_taken = flag_neg;              // BLT
            3'b101: branch_taken = ~flag_neg;             // BGE
            3'b110: branch_taken = ~flag_carry;           // BLTU
            3'b111: branch_taken = flag_carry;            // BGEU
            default: branch_taken = 1'b0;                 // No branch
        endcase
    end

endmodule

`endif
