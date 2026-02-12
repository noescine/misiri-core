`timescale 1ns / 1ps
`ifndef MISIRI_DECODE_V
`define MISIRI_DECODE_V

`include "../common/instructions.v"
`include "../common/imm_types.v"

module decode (
    input  wire [31:0] instr,
    input  wire        valid,        // optional: instruction valid (from IFQ)

    // register indices
    output reg  [4:0] rs1,
    output reg  [4:0] rs2,
    output reg  [4:0] rd,

    // ALU
    output reg  [3:0] alu_fn,        // ALU op encoding (same as your ALU.v constants)
    output reg        alu_src,       // 0 -> rs2, 1 -> imm (maps from alu_src_b_imm)

    // Register write / memory
    output reg        reg_write,
    output reg        is_load,
    output reg        is_store,
    output reg  [1:0] lsu_size,      // 00=byte,01=halfword,10=word
    // simplified write-enable mask (byte enables) - LSU should refine with address offset
    output reg  [3:0] lsu_we,

    // Writeback select
    // 00 = ALU, 01 = MEM, 10 = PC+4
    output reg  [1:0] wb_sel,
    // Branch type (funct3)
    output reg  [2:0] branch_type,

    // immediates (full 32-bit values) - these are required by misiri_top / pc_mux
    output wire [31:0] imm_I,
    output wire [31:0] imm_B,
    output wire [31:0] imm_J,

    // high level control signals
    output reg        is_branch,
    output reg        is_jal,
    output reg        is_jalr,

    // aux
    output reg        is_alu
);

    // local fields
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // internal imm_type used by imm_gen
    reg [2:0] imm_type;

    // defaults and decode
    always @(*) begin
        // default assignments
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd  = instr[11:7];

        alu_fn        = `ALU_ADD;      // map to ALU.v encodings (use your defines)
        alu_src       = 1'b0;          // default: use rs2
        is_alu        = 1'b0;

        reg_write     = 1'b0;
        is_load       = 1'b0;
        is_store      = 1'b0;
        lsu_size      = 2'b10;         // word by default
        lsu_we        = 4'b0000;

        wb_sel        = 2'b00;         // ALU result by default
        branch_type   = 3'b000;
        imm_type      = `IMM_NONE;     // use imm_types.v
        is_jal        = 1'b0;
        is_jalr       = 1'b0;
        is_branch     = 1'b0;

        case (opcode)

            // R-type
            `OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                is_alu    = 1'b1;
                imm_type  = `IMM_NONE;
                case ({funct7, funct3})
                    {7'b0000000,3'b000}: alu_fn = `ALU_ADD;
                    {7'b0100000,3'b000}: alu_fn = `ALU_SUB;
                    {7'b0000000,3'b111}: alu_fn = `ALU_AND;
                    {7'b0000000,3'b110}: alu_fn = `ALU_OR;
                    {7'b0000000,3'b100}: alu_fn = `ALU_XOR;
                    {7'b0000000,3'b001}: alu_fn = `ALU_SLL;
                    {7'b0000000,3'b101}: alu_fn = `ALU_SRL;
                    {7'b0100000,3'b101}: alu_fn = `ALU_SRA;
                    {7'b0000000,3'b010}: alu_fn = `ALU_SLT;
                    {7'b0000000,3'b011}: alu_fn = `ALU_SLTU;
                    default: alu_fn = `ALU_NOP;
                endcase
            end

            // I-type ALU (ADDI, XORI, etc.)
            `OPCODE_ITYPE: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1;   // use immediate
                is_alu        = 1'b1;
                imm_type      = `IMM_I;
                case(funct3)
                    3'b000: alu_fn = `ALU_ADD; // ADDI
                    3'b010: alu_fn = `ALU_SLT; // SLTI
                    3'b011: alu_fn = `ALU_SLTU;// SLTIU
                    3'b100: alu_fn = `ALU_XOR; // XORI
                    3'b110: alu_fn = `ALU_OR;  // ORI
                    3'b111: alu_fn = `ALU_AND; // ANDI
                    3'b001: alu_fn = `ALU_SLL; // SLLI
                    3'b101: alu_fn = funct7[5] ? `ALU_SRA : `ALU_SRL; // SRLI/SRAI
                    default: alu_fn = `ALU_NOP;
                endcase
            end

            // Load
            `OPCODE_LOAD: begin
                reg_write     = 1'b1;
                is_load       = 1'b1;
                alu_src       = 1'b1;   // address = rs1 + imm
                wb_sel        = 2'b01;  // MEM
                alu_fn        = `ALU_ADD; // compute address
                imm_type      = `IMM_I;
                // mem size from funct3
                case(funct3)
                    3'b000: lsu_size = 2'b00; // LB
                    3'b001: lsu_size = 2'b01; // LH
                    3'b010: lsu_size = 2'b10; // LW
                    3'b100: lsu_size = 2'b00; // LBU
                    3'b101: lsu_size = 2'b01; // LHU
                    default: lsu_size = 2'b10;
                endcase
            end

            // Store
            `OPCODE_STORE: begin
                is_store      = 1'b1;
                alu_src       = 1'b1;
                alu_fn        = `ALU_ADD;
                imm_type      = `IMM_S;
                // store size
                case(funct3)
                    3'b000: lsu_size = 2'b00; // SB
                    3'b001: lsu_size = 2'b01; // SH
                    3'b010: lsu_size = 2'b10; // SW
                    default: lsu_size = 2'b10;
                endcase
                // generate naive byte enables (LSU should refine using address LSBs)
                case (lsu_size)
                    2'b10: lsu_we = 4'b1111; // word
                    2'b01: lsu_we = 4'b0011; // half (lower half default)
                    2'b00: lsu_we = 4'b0001; // byte (lowest byte)
                    default: lsu_we = 4'b0000;
                endcase
            end

            // Branch
            `OPCODE_BRANCH: begin
                alu_fn      = `ALU_SUB;
                branch_type = funct3;
                imm_type    = `IMM_B;
                is_branch   = 1'b1;
            end

            // JAL / JALR
            `OPCODE_JAL: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1;   // for PC+imm semantics in some ALU usage
                wb_sel        = 2'b10;  // PC+4
                imm_type      = `IMM_J;
                is_jal        = 1'b1;
            end

            `OPCODE_JALR: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1;
                wb_sel        = 2'b10;
                imm_type      = `IMM_I;
                is_jalr       = 1'b1;
            end

            // LUI / AUIPC
            `OPCODE_LUI: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1;
                alu_fn        = `ALU_ADD;
                wb_sel        = 2'b00;
                imm_type      = `IMM_U;
                // AUIPC set via opcode AUIPC below, LUI similarly uses imm U
            end

            `OPCODE_AUIPC: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1;
                alu_fn        = `ALU_ADD;
                wb_sel        = 2'b00;
                imm_type      = `IMM_U;
            end

            default: begin
                // For unsupported opcodes: no-op / illegal instruction behavior to be defined elsewhere
                alu_fn = `ALU_NOP;
                imm_type = `IMM_NONE;
            end

        endcase
    end // always

    // ---------------------------------------------------------------------
    // Immediate generator instantiation (assumes imm_gen has this simple interface)
    // imm_gen: input instr, imm_type -> imm_I, imm_B, imm_J outputs
    // If your imm_gen uses a different interface, adapt accordingly.
    // ---------------------------------------------------------------------
    wire [31:0] imm_ext;

    imm_gen u_imm (
        .instr   (instr),
        .imm_type(imm_type),
        .imm_ext (imm_ext)          // único puerto de salida
    );

    // ---------------------------------------------------------------------
    // Asignación de las tres salidas de inmediato
    // ---------------------------------------------------------------------
    // imm_I se usa para ALU (I, S, U) y JALR
    assign imm_I = imm_ext;   // siempre el inmediato decodificado (0 si IMM_NONE)

    // imm_B solo para branches
    assign imm_B = (imm_type == `IMM_B) ? imm_ext : 32'b0;

    // imm_J solo para JAL
    assign imm_J = (imm_type == `IMM_J) ? imm_ext : 32'b0;

endmodule
`endif
