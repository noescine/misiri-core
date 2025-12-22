`timescale 1ns / 1ps
`ifndef MISIRI_TOP_V
`define MISIRI_TOP_V

`include "../common/opcodes.v"
`include "../common/alu_ops.v"
`include "../common/imm_types.v"

module misiri_top (
    input  wire clk,
    input  wire rst,

    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire        instr_valid_out
);

    // ----------------------------
    // IMEM simple (ROM)
    // ----------------------------
    localparam IMEM_WORDS = 2048;
    reg [31:0] imem [0:IMEM_WORDS-1];

    integer i;
    initial begin
        for (i = 0; i < IMEM_WORDS; i = i + 1)
            imem[i] = 32'h00000013; // NOP
    end

    // ----------------------------
    // PC
    // ----------------------------
    wire [31:0] pc_curr;
    wire [31:0] pc_next;

    assign pc_next = pc_curr + 32'd4;

    pc_reg u_pc (
        .clk(clk),
        .rst(rst),
        .pc_en(1'b1),
        .pc_next(pc_next),
        .pc(pc_curr)
    );

    assign pc_out = pc_curr;

    // ----------------------------
    // IMEM read
    // ----------------------------
    wire [31:0] imem_rdata;
    assign imem_rdata = imem[pc_curr[31:2]];

    // ----------------------------
    // IFETCH
    // ----------------------------
    wire [31:0] if_instr;
    wire        if_valid;

    ifetch u_ifetch (
        .clk(clk),
        .rst(rst),
        .pc(pc_curr),
        .imem_rdata(imem_rdata),
        .instr(if_instr),
        .instr_valid(if_valid)
    );

    assign instr_out = if_instr;
    assign instr_valid_out = if_valid;

    // ----------------------------
    // IF/ID
    // ----------------------------
    reg [31:0] id_pc;
    always @(posedge clk) begin
        if (rst) id_pc <= 32'd0;
        else     id_pc <= pc_curr;
    end

    wire [31:0] id_instr = if_instr;

    // ----------------------------
    // DECODE
    // ----------------------------
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [3:0] alu_op;
    wire alu_src_a_pc, alu_src_b_imm;
    wire reg_write;
    wire mem_read, mem_write;
    wire [1:0] wb_sel;
    wire [2:0] branch_type;
    wire [2:0] imm_type;

    decode u_decode (
        .instr(id_instr),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .alu_op(alu_op),
        .alu_src_a_pc(alu_src_a_pc),
        .alu_src_b_imm(alu_src_b_imm),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .wb_sel(wb_sel),
        .branch_type(branch_type),
        .imm_type(imm_type)
    );

    // ----------------------------
    // IMM GEN
    // ----------------------------
    wire [31:0] imm_ext;

    imm_gen u_imm (
        .instr(id_instr),
        .imm_type(imm_type),
        .imm_ext(imm_ext)
    );

    // ----------------------------
    // REGFILE
    // ----------------------------
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] wb_data;

    assign wb_data = 32'd0; // stub de debug

    regfile_32x32 u_regfile (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .write_en(reg_write),
        .rd_addr(rd_addr),
        .rd_data(wb_data)
    );

endmodule

`endif
