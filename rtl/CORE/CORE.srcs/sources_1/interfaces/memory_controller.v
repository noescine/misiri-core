`timescale 1ns / 1ps
`ifndef MISIRI_MEMORY_CONTROLLER_V
`define MISIRI_MEMORY_CONTROLLER_V

// -----------------------------------------------------------------------------
// memory_controller.v
// - IMEM region: 0x0000 .. 0x1FFF  (8192 bytes -> 2048 words)
// - DMEM region: 0x2000 .. 0x23FF  (1024 bytes -> 256 words)
// - Interface:
//     .clk, .addr (byte), .wdata (word), .mem_read (load), .mem_write (store),
//     .size (00=b,01=h,10=w), .rdata (word), .ready (indica dato válido)
// - rdata sale registrado.
// -----------------------------------------------------------------------------

module memory_controller (
    input  wire        clk,
    input  wire [31:0] addr,       // byte address
    input  wire [31:0] wdata,      // data to write (word)
    input  wire        mem_read,   // load (DMEM)
    input  wire        mem_write,  // store (DMEM)
    input  wire [1:0]  size,       // 00=byte,01=half,10=word  (para stores/loads)
    output reg  [31:0] rdata,      // registered read data (word)
    output reg         ready       // dato válido (para fetch o load)
);

    // address ranges
    wire is_imem = (addr < 32'h00002000);
    wire is_dmem = (addr >= 32'h00002000) && (addr < 32'h00002400);

    // internal outputs
    wire [31:0] imem_rdata;
    wire [31:0] dmem_rdata;

    // instantiate IMEM
    imem u_imem (
        .clk(clk),
        .addr(addr),
        .rdata(imem_rdata)
    );

    // dmem expects offset inside DMEM (addr - 0x2000)
    wire [31:0] dmem_offset = addr - 32'h00002000;
    // pass low bits (10 bits) to dmem
    wire [9:0] dmem_addr = dmem_offset[9:0];

    // We need a write enable and size for dmem:
    dmem u_dmem (
        .clk(clk),
        .we(mem_write && is_dmem),
        .size(size),
        .addr(dmem_addr),
        .wdata(wdata),
        .rdata(dmem_rdata)
    );

    // Registered multiplexing + ready flag
    always @(posedge clk) begin
        // ready indicates rdata valid this cycle (registered)
        // For simplicity consider ready = 1 once the imem/dmem produced rdata (synchronous)
        ready <= 1'b0;
        if (is_imem) begin
            rdata <= imem_rdata;
            ready <= 1'b1;
        end else if (is_dmem) begin
            rdata <= dmem_rdata;
            ready <= 1'b1;
        end else begin
            rdata <= 32'd0;
            ready <= 1'b1;
        end
    end

endmodule

`endif
