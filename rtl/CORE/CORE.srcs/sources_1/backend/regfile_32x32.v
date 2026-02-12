`timescale 1ns / 1ps
`ifndef MISIRI_REGFILE_32X32_V
`define MISIRI_REGFILE_32X32_V

// Regfile 32x32
// - Escritura síncrona (posedge clk)
// - Lecturas combinacionales
// - x0 = 0 siempre
// - Sugerencia: ram_style = "block" para que Vivado intente mapear a BRAM

module regfile_32x32 (
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    input  wire        write_en,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data
);

    (* ram_style = "block" *)
    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'd0;
        end else begin
            // write on posedge (write-first not assumed)
            if (write_en && (rd_addr != 5'd0)) regs[rd_addr] <= rd_data;
            regs[0] <= 32'd0; // force x0 = 0
        end
    end

    // combinational reads (for ID stage)
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];

endmodule

`endif
