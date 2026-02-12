`timescale 1ns / 1ps
`ifndef MISIRI_MEMORY_CONTROLLER_V
`define MISIRI_MEMORY_CONTROLLER_V

// Memory controller simple y síncrono
// - Region IMEM: 0x0000 .. 0x1FFF  (8192 bytes -> 2048 words)
// - Region DMEM: 0x2000 .. 0x23FF  (1024 bytes -> 256 words)
// - mem_read: LOAD request (only valid for DMEM reads)  -- controller decide region
// - mem_write: STORE request (only for DMEM) with byte enables from size+addr
// - rdata: registered read data (returned next cycle)

module memory_controller (
    input  wire        clk,
    input  wire [31:0] addr,       // byte address (core space)
    input  wire [31:0] wdata,      // data to write (word aligned)
    input  wire        mem_read,   // load request (DMEM)
    input  wire        mem_write,  // store request (DMEM)
    input  wire [1:0]  size,       // 00=byte,01=half,10=word (affects write BE)
    output reg  [31:0] rdata       // registered output (available next cycle)
);

    // address ranges (byte)
    localparam IMEM_LIMIT = 32'h00002000; // 8192
    localparam DMEM_BASE  = 32'h00002000; // start of DMEM
    localparam DMEM_LIMIT = 32'h00002400; // 9216

    wire is_imem = (addr < IMEM_LIMIT);
    wire is_dmem = (addr >= DMEM_BASE) && (addr < DMEM_LIMIT);

    // IMEM instance
    wire [31:0] imem_rdata;
    imem u_imem (
        .clk(clk),
        .addr(addr),    // imem takes full byte addr; it uses [11:2]
        .rdata(imem_rdata)
    );

    // DMEM instance -- provide offset inside DMEM (0 .. 1023 bytes)
    wire [31:0] dmem_addr_off;
    assign dmem_addr_off = addr - DMEM_BASE;
    
    wire [9:0] dmem_word_idx; // 256 words
    assign dmem_word_idx = dmem_addr_off[11:2];
    

    // form byte-enable for writes based on size and addr[1:0]
    reg [3:0] be;
    always @(*) begin
        be = 4'b0000;
        if (mem_write && is_dmem) begin
            case (size)
                2'b10: be = 4'b1111; // SW
                2'b01: begin // SH
                    if (addr[1] == 1'b0) be = 4'b0011; else be = 4'b1100;
                end
                2'b00: begin // SB
                    case (addr[1:0])
                        2'b00: be = 4'b0001;
                        2'b01: be = 4'b0010;
                        2'b10: be = 4'b0100;
                        2'b11: be = 4'b1000;
                    endcase
                end
                default: be = 4'b1111;
            endcase
        end
    end

    dmem u_dmem (
        .clk(clk),
        .we(mem_write && is_dmem),
        .be(be),
        .addr(dmem_word_idx),
        .wdata(wdata),
        .rdata(dmem_rdata)
    );

    // registered multiplex: IMEM has priority for fetch (when addr in imem)
    always @(posedge clk) begin
        if (is_imem) rdata <= imem_rdata;
        else if (is_dmem) rdata <= dmem_rdata;
        else rdata <= 32'd0;
    end

endmodule

`endif
