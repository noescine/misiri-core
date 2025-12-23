`timescale 1ns / 1ps
`ifndef MISIRI_TOP_V
`define MISIRI_TOP_V

`include "common/instructions.v"
`include "common/imm_types.v"

module misiri_top (
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] pc_out,
    output wire [31:0] instr_out
);

    // ------------------------------------------------------------------
    // PC
    // ------------------------------------------------------------------
    wire [31:0] pc_curr;
    wire [31:0] pc_next;

    pc_reg u_pc (
        .clk(clk),
        .rst(rst),
        .pc_en(1'b1),
        .pc_next(pc_next),
        .pc(pc_curr)
    );
    assign pc_out = pc_curr;

    // ------------------------------------------------------------------
    // IF/ID pipeline registers (fetch result captured here)
    // ------------------------------------------------------------------
    reg [31:0] id_pc;
    reg [31:0] id_instr;

    // ------------------------------------------------------------------
    // Decode stage signals
    // ------------------------------------------------------------------
    wire [4:0]  rs1_addr;
    wire [4:0]  rs2_addr;
    wire [4:0]  rd_addr;

    wire [3:0]  alu_op;
    wire        alu_src_a_pc;
    wire        alu_src_b_imm;
    wire        reg_write;
    wire        mem_read_sig;
    wire        mem_write_sig;
    wire [1:0]  mem_size;   // 00=byte,01=half,10=word
    wire        mem_signed; // (decode would set for LB/LH vs LBU/LHU) - if not present assume 1
    wire [1:0]  wb_sel;
    wire [2:0]  branch_type;
    wire [2:0]  imm_type;
    wire        is_jal;
    wire        is_jalr;

    decode u_decode (
        .instr(id_instr),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .alu_op(alu_op),
        .alu_src_a_pc(alu_src_a_pc),
        .alu_src_b_imm(alu_src_b_imm),
        .reg_write(reg_write),
        .mem_read(mem_read_sig),
        .mem_write(mem_write_sig),
        .mem_size(mem_size),
        .wb_sel(wb_sel),
        .branch_type(branch_type),
        .imm_type(imm_type),
        .is_jal(is_jal),
        .is_jalr(is_jalr)
    );

    // ------------------------------------------------------------------
    // Immediate generator
    // ------------------------------------------------------------------
    wire [31:0] imm_ext;
    imm_gen u_imm (
        .instr(id_instr),
        .imm_type(imm_type),
        .imm_ext(imm_ext)
    );

    // ------------------------------------------------------------------
    // Register file (BRAM-friendly)
    // ------------------------------------------------------------------
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
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

    // ------------------------------------------------------------------
    // Simple 1-cycle forwarding (prev EX -> current ID)
    // ------------------------------------------------------------------
    reg  [4:0]  last_rd;
    reg         last_reg_write;
    reg [31:0]  last_alu_result;

    always @(posedge clk) begin
        if (rst) begin
            last_rd         <= 5'd0;
            last_reg_write  <= 1'b0;
            last_alu_result <= 32'd0;
        end else begin
            last_rd         <= rd_addr;
            last_reg_write  <= reg_write;
            last_alu_result <= alu_result; // alu_result is driven below
        end
    end

    wire [31:0] rs1_raw = rs1_data;
    wire [31:0] rs2_raw = rs2_data;

    wire use_forward_rs1 = (last_reg_write && (last_rd != 5'd0) && (last_rd == rs1_addr));
    wire use_forward_rs2 = (last_reg_write && (last_rd != 5'd0) && (last_rd == rs2_addr));

    wire [31:0] rs1_for_alu = use_forward_rs1 ? last_alu_result : rs1_raw;
    wire [31:0] rs2_for_alu = use_forward_rs2 ? last_alu_result : rs2_raw;

    // ------------------------------------------------------------------
    // ALU
    // ------------------------------------------------------------------
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_result;
    wire        flag_carry, flag_zero, flag_neg;

    assign alu_a = (alu_src_a_pc) ? id_pc : rs1_for_alu;
    assign alu_b = (alu_src_b_imm) ? imm_ext : rs2_for_alu;

    alu u_alu (
        .a(alu_a),
        .b(alu_b),
        .alu_op(alu_op),
        .result(alu_result),
        .flag_carry(flag_carry),
        .flag_zero(flag_zero),
        .flag_neg(flag_neg)
    );

    // ------------------------------------------------------------------
    // Branch unit
    // ------------------------------------------------------------------
    wire branch_taken;
    branch_unit u_branch (
        .branch_type(branch_type),
        .flag_zero(flag_zero),
        .flag_neg(flag_neg),
        .flag_carry(flag_carry),
        .branch_taken(branch_taken)
    );

    // ------------------------------------------------------------------
    // LSU (Load / Store Unit)
    // ------------------------------------------------------------------
    wire [31:0] load_data;
    wire [31:0] store_data;
    // store_we (to memory_controller) - we use mem_write_sig directly
    wire        store_we = mem_write_sig;

    LSU u_lsu (
        .mem_word(mem_rdata),
        .rs2_data(rs2_data),
        .addr_lsb(alu_result[1:0]),
        .mem_size(mem_size),
        .mem_signed(mem_signed),      // si decode no provee, conecta 1'b1 por ahora
        .is_load(mem_read_sig),
        .is_store(mem_write_sig),
        .load_data(load_data),
        .store_data(store_data)
    );

    // ------------------------------------------------------------------
    // Memory controller (IMEM + DMEM)
    // ------------------------------------------------------------------
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire        mem_read;   // hacia controller (loads)
    wire        mem_write;  // hacia controller (stores)
    wire [31:0] mem_rdata;
    wire        mem_ready;

    // direccion a memoria: LOAD/STORE usan ALU, fetch usa PC
    assign mem_addr  = (mem_read_sig || mem_write_sig) ? alu_result : pc_curr;
    assign mem_wdata = store_data;
    assign mem_read  = mem_read_sig;
    assign mem_write = store_we;

    memory_controller u_mem (
        .clk(clk),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .size(mem_size),
        .rdata(mem_rdata),
        .ready(mem_ready)
    );

    // ------------------------------------------------------------------
    // PC MUX
    // ------------------------------------------------------------------
    pc_mux u_pc_mux (
        .pc_curr(pc_curr),
        .imm_B(imm_ext),
        .imm_J(imm_ext),
        .imm_I(imm_ext),
        .rs1_val(rs1_for_alu),
        .branch_taken(branch_taken),
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .pc_next(pc_next)
    );

    // ------------------------------------------------------------------
    // Writeback selection
    // ------------------------------------------------------------------
    assign wb_data = (wb_sel == 2'b01) ? load_data :
                     (wb_sel == 2'b10) ? (id_pc + 32'd4) :
                                         alu_result;

    // ------------------------------------------------------------------
    // IF/ID pipeline registers: capture the fetched instruction when mem is ready
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            id_pc    <= 32'd0;
            id_instr <= 32'h00000013; // NOP
        end else if (mem_ready) begin
            id_pc    <= pc_curr;
            id_instr <= mem_rdata;    // fetch result (IMEM word)
        end
    end

    // debug output
    assign instr_out = id_instr;

endmodule

`endif
