`timescale 1ns / 1ps
`ifndef MISIRI_ALU_V
`define MISIRI_ALU_V

`include "../common/instructions.v"

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_op,

    output reg  [31:0] result,
    output wire        flag_carry,
    output wire        flag_zero,
    output wire        flag_neg
);

    always @(*) begin
        case (alu_op)
            `ALU_ADD:  result = a + b;
            `ALU_SUB:  result = a - b;
            `ALU_AND:  result = a & b;
            `ALU_OR:   result = a | b;
            `ALU_XOR:  result = a ^ b;
            `ALU_SLL:  result = a << b[4:0];
            `ALU_SRL:  result = a >> b[4:0];
            `ALU_SRA:  result = $signed(a) >>> b[4:0];
            `ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
            default:   result = 32'd0;
        endcase
    end

    // ---------- FLAG CARRY CORREGIDO ----------
    wire [32:0] add_result = {1'b0, a} + {1'b0, b};
    wire [32:0] sub_result = {1'b0, a} + {1'b0, ~b} + 33'd1; // a - b = a + ~b + 1

    assign flag_carry = (alu_op == `ALU_ADD) ? add_result[32] :
                        (alu_op == `ALU_SUB) ? sub_result[32] :
                        1'b0;
    // ------------------------------------------

    assign flag_zero = (result == 32'd0);
    assign flag_neg  = result[31];

endmodule

`endif