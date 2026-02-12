`timescale 1ns / 1ps

module misiri_top (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         core_enable,
    input  wire [31:0]  boot_pc,

    // Instruction bus
    output wire [31:0]  i_addr,
    output wire         i_req,
    input  wire [31:0]  i_rdata,

    // Data bus
    output wire [31:0]  d_addr,
    output wire [31:0]  d_wdata,
    output wire [3:0]   d_we,
    output wire         d_req,
    input  wire [31:0]  d_rdata,

    // Interrupts (dummy)
    input  wire [7:0]   irq_vect,
    output wire         irq_ack,

    output wire [31:0]  dbg_pc
);

    // --------------------------------------------------------------
    // PC
    // --------------------------------------------------------------
    wire [31:0] pc;
    wire [31:0] pc_next;
    wire        branch_taken;

    assign dbg_pc = pc;

    pc_reg #(.RESET_VECTOR(32'h00000000)) u_pc_reg (
        .clk     (clk),
        .rst_n   (rst_n),
        .pc_en   (core_enable),
        .pc_next (pc_next),
        .pc      (pc),
        .boot_pc (boot_pc)
    );

    assign i_addr = pc;
    assign i_req  = core_enable;

    // --------------------------------------------------------------
    // DECODE (tu módulo, ya corregido)
    // --------------------------------------------------------------
    wire [4:0]  rs1, rs2, rd;
    wire [3:0]  alu_fn;
    wire        alu_src;
    wire        reg_write;
    wire        is_load;
    wire        is_store;
    wire [1:0]  lsu_size;
    wire [1:0]  wb_sel;
    wire [2:0]  branch_type;
    wire [31:0] imm_I, imm_B, imm_J;
    wire        is_jal;
    wire        is_jalr;

    decode u_decode (
        .instr      (i_rdata),
        .valid      (1'b1),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .alu_fn     (alu_fn),
        .alu_src    (alu_src),
        .reg_write  (reg_write),
        .is_load    (is_load),
        .is_store   (is_store),
        .lsu_size   (lsu_size),
        .lsu_we     (),          // no usado
        .wb_sel     (wb_sel),
        .branch_type(branch_type),
        .imm_I      (imm_I),
        .imm_B      (imm_B),
        .imm_J      (imm_J),
        .is_jal     (is_jal),
        .is_jalr    (is_jalr),
        .is_alu     (),
        .is_branch  ()
    );

    // --------------------------------------------------------------
    // REGISTER FILE (reset adaptado a rst_n)
    // --------------------------------------------------------------
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] rd_data;

    regfile_32x32 u_regfile (
        .clk      (clk),
        .rst      (~rst_n),      // temporal, idealmente modificar el módulo a rst_n
        .rs1_addr (rs1),
        .rs2_addr (rs2),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data),
        .write_en (reg_write),
        .rd_addr  (rd),
        .rd_data  (rd_data)
    );

    // --------------------------------------------------------------
    // ALU (con flag_carry corregido)
    // --------------------------------------------------------------
    wire [31:0] alu_b = alu_src ? imm_I : rs2_data;
    wire [31:0] alu_result;
    wire        flag_zero, flag_neg, flag_carry;

    alu u_alu (
        .a          (rs1_data),
        .b          (alu_b),
        .alu_op     (alu_fn),
        .result     (alu_result),
        .flag_carry (flag_carry),
        .flag_zero  (flag_zero),
        .flag_neg   (flag_neg)
    );

    // --------------------------------------------------------------
    // BRANCH UNIT
    // --------------------------------------------------------------
    branch_unit u_branch (
        .branch_type (branch_type),
        .flag_zero   (flag_zero),
        .flag_neg    (flag_neg),
        .flag_carry  (flag_carry),
        .branch_taken(branch_taken)
    );

    // --------------------------------------------------------------
    // PC MUX (usa inmediatos del decode)
    // --------------------------------------------------------------
    pc_mux u_pc_mux (
        .pc_curr      (pc),
        .imm_B        (imm_B),
        .imm_J        (imm_J),
        .imm_I        (imm_I),
        .rs1_val      (rs1_data),
        .branch_taken (branch_taken),
        .is_jal       (is_jal),
        .is_jalr      (is_jalr),
        .pc_next      (pc_next)
    );

    // --------------------------------------------------------------
    // LSU - ALINEACIÓN (combinacional)
    // --------------------------------------------------------------
    wire [31:0] load_data_aligned;
    wire [31:0] store_data_formatted;

    lsu_align u_lsu_align (
        .mem_word   (d_rdata),
        .rs2_data   (rs2_data),
        .addr_lsb   (alu_result[1:0]),
        .mem_size   (lsu_size),
        .mem_signed (1'b0),      // ⚠️ PENDIENTE: conectar desde decode (agregar output mem_signed)
        .is_load    (is_load),
        .is_store   (is_store),
        .load_data  (load_data_aligned),
        .store_data (store_data_formatted)
    );

    // --------------------------------------------------------------
    // LSU - INTERFAZ DE BUS (combinacional)
    // --------------------------------------------------------------
    lsu_bus_if u_lsu_bus_if (
        .addr_base   (alu_result),
        .store_data  (store_data_formatted),
        .mem_read    (is_load),
        .mem_write   (is_store),
        .mem_size    (lsu_size),
        .addr_lsb    (alu_result[1:0]),
        .d_addr      (d_addr),
        .d_wdata     (d_wdata),
        .d_we        (d_we),
        .d_req       (d_req)
    );

    // --------------------------------------------------------------
    // WRITEBACK MUX
    // --------------------------------------------------------------
    assign rd_data =
        (wb_sel == 2'b00) ? alu_result :
        (wb_sel == 2'b01) ? load_data_aligned :
        (wb_sel == 2'b10) ? (pc + 32'd4) :
        32'd0;

    // --------------------------------------------------------------
    // INTERRUPCIONES (dummy)
    // --------------------------------------------------------------
    assign irq_ack = 1'b0;

endmodule