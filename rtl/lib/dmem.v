`timescale 1ns / 1ps
`ifndef MISIRI_DMEM_V
`define MISIRI_DMEM_V

// -----------------------------------------------------------------------------
// DMEM: 1024 bytes (1 KiB)
// - 256 palabras de 32 bits
// - Escritura con byte-enable (SB / SH / SW)
// - Lectura síncrona (registered read)
// - Implementable en BRAM
// -----------------------------------------------------------------------------

module dmem (
    input  wire        clk,
    input  wire        we,         // write enable
    input  wire [3:0]  be,         // byte enables
    input  wire [9:0]  addr,       // word index (0..255)
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);

    localparam WORDS = 256;

    (* ram_style = "block" *)
    reg [31:0] mem [0:WORDS-1];

    reg [31:0] cur;   // ✅ DECLARADO FUERA (legal en Verilog)

    integer i;
    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            mem[i] = 32'd0;
    end

    // ------------------------------------------------------------------
    // Synchronous read + write
    // Read-first behavior (RISC-V friendly)
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        // lectura registrada
        rdata <= mem[addr];

        if (we) begin
            cur = mem[addr];
            if (be[0]) cur[7:0]   = wdata[7:0];
            if (be[1]) cur[15:8]  = wdata[15:8];
            if (be[2]) cur[23:16] = wdata[23:16];
            if (be[3]) cur[31:24] = wdata[31:24];
            mem[addr] <= cur;
        end
    end

endmodule

`endif
