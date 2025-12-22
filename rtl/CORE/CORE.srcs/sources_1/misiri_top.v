`timescale 1ns / 1ps
`ifndef MISIRI_TOP_V
`define MISIRI_TOP_V

`include "common/opcodes.v"
`include "common/alu_ops.v"
`include "common/imm_types.v"

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
        // Programa de prueba:
        // 0: ADDI x1, x0, 5        -> x1 = 5
        // 1: ADDI x2, x0, 10       -> x2 = 10
        // 2: ADD  x3, x1, x2       -> x3 = 15
        // 3: ADDI x4, x0, -3       -> x4 = -3
        // 4: SLT  x5, x4, x1       -> x5 = (x4 < x1) ? 1 : 0
        // 5: JAL  x0, 8            -> salto incondicional corto (salta a instr index 7)
        // 6: ADDI x6, x0, 1        -> (se saltará)
        // 7: ADDI x7, x0, 2        -> x7 = 2 (se ejecuta por JAL)
        // 8: ADD  x8, x6, x7       -> x8 = x6 + x7 = 2
        // resto: NOP

        // Inicializa todo a NOP
        for (i = 0; i < IMEM_WORDS; i = i + 1)
            imem[i] = 32'h00000013; // NOP (ADDI x0,x0,0)

        // Cargar programa (encoding RV32I)
        imem[0] = 32'h00500093; // ADDI x1, x0, 5
        imem[1] = 32'h00A00113; // ADDI x2, x0, 10
        imem[2] = 32'h002081B3; // ADD x3, x1, x2
        imem[3] = 32'hFFD00213; // ADDI x4, x0, -3  (imm = 0xFFD -> -3)
        imem[4] = 32'h001222B3; // SLT x5, x4, x1
        imem[5] = 32'h0100006F; // JAL x0, 8
        imem[6] = 32'h00100313; // ADDI x6, x0, 1  (se saltará)
        imem[7] = 32'h00200393; // ADDI x7, x0, 2
        imem[8] = 32'h007C0433; // ADD x8, x6, x7
    end

    // ----------------------------
    // PC / PC MUX wires
    // ----------------------------
    wire [31:0] pc_curr;
    wire [31:0] pc_next;

    // We'll compute pc_next with pc_mux instance below

    // ----------------------------
    // PC register
    // ----------------------------
    pc_reg u_pc (
        .clk(clk),
        .rst(rst),
        .pc_en(1'b1),
        .pc_next(pc_next),
        .pc(pc_curr)
    );
    assign pc_out = pc_curr;

    // ----------------------------
    // IMEM read (safe index)
    // ----------------------------
    wire [31:0] imem_rdata;
    wire [31:0] imem_idx = (pc_curr[31:2] < IMEM_WORDS) ? pc_curr[31:2] : 32'd0;
    assign imem_rdata = imem[imem_idx];

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
    // IF/ID pipeline registers (align pc and instr)
    // ----------------------------
    reg [31:0] id_pc;
    reg [31:0] id_instr;        // ahora SI guardamos la instrucción en el registro ID
    
    always @(posedge clk) begin
        if (rst) begin
            id_pc    <= 32'd0;
            id_instr <= 32'd0;
        end else begin
            id_pc    <= pc_curr;
            id_instr <= if_instr; // captura estable y sin desalineación
        end
    end
    // ahora decode y imm_gen usan id_instr (registrado)
    

    // ----------------------------
    // DECODE
    // ----------------------------
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [3:0] alu_op;
    wire       alu_src_a_pc, alu_src_b_imm;
    wire       reg_write;
    wire       mem_read, mem_write;
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

    // Detect JAL / JALR from opcode bits (no change to decode)
    wire [6:0] id_opcode = id_instr[6:0];
    wire is_jal  = (id_opcode == `OPCODE_JAL);
    wire is_jalr = (id_opcode == `OPCODE_JALR);

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
    // wb_data selected below from ALU / MEM / PC+4
    wire [31:0] wb_data;

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

    // ----------------------------
    // ALU instantiation
    // ----------------------------
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_result;
    wire        flag_carry;
    wire        flag_zero;
    wire        flag_neg;

    assign alu_a = (alu_src_a_pc) ? id_pc : rs1_data;
    assign alu_b = (alu_src_b_imm) ? imm_ext : rs2_data;

    alu u_alu (
        .a(alu_a),
        .b(alu_b),
        .alu_op(alu_op),
        .result(alu_result),
        .flag_carry(flag_carry),
        .flag_zero(flag_zero),
        .flag_neg(flag_neg)
    );

    // ----------------------------
    // Branch Unit instantiation
    // ----------------------------
    wire branch_taken;
    branch_unit u_branch (
        .branch_type(branch_type),
        .flag_zero(flag_zero),
        .flag_neg(flag_neg),
        .flag_carry(flag_carry),
        .branch_taken(branch_taken)
    );

    // ----------------------------
    // PC MUX instantiation
    // ----------------------------
    wire [31:0] pc_mux_out;
    pc_mux u_pc_mux (
        .pc_curr(pc_curr),
        .imm_B(imm_ext),
        .imm_J(imm_ext),
        .imm_I(imm_ext),
        .rs1_val(rs1_data),
        .branch_taken(branch_taken),
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .pc_next(pc_mux_out)
    );

    // Connect pc_next to pc_reg input
    assign pc_next = pc_mux_out;

    // ----------------------------
    // Simple data memory (not used now) 
    // ----------------------------
    wire [31:0] dmem_rdata;
    assign dmem_rdata = 32'd0; // placeholder, no data memory implemented

    // ----------------------------
    // Writeback selection (wb_sel):
    // 00 -> ALU
    // 01 -> MEM
    // 10 -> PC+4 (for JAL)
    // ----------------------------
    assign wb_data = (wb_sel == 2'b01) ? dmem_rdata :
                     (wb_sel == 2'b10) ? (id_pc + 32'd4) : alu_result;


endmodule

`endif
