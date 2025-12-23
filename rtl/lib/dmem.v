`timescale 1ns / 1ps
`ifndef MISIRI_DMEM_V
`define MISIRI_DMEM_V

// -----------------------------------------------------------------------------
// dmem.v
// DMEM: Byte-addressable RAM (1024 bytes)
// - Addr: byte offset dentro de DMEM (0..1023)
// - Soporta escritura byte/half/word mediante 'we' y 'size'.
// - Little-endian.
// - rdata sale registrada al siguiente flanco (word-read).
// -----------------------------------------------------------------------------

module dmem (
    input  wire        clk,
    input  wire        we,        // write enable (store)
    input  wire [1:0]  size,      // 00=byte,01=half,10=word
    input  wire [9:0]  addr,      // byte offset (0..1023) -> 10 bits
    input  wire [31:0] wdata,     // write word (store_data)
    output reg  [31:0] rdata
);

    localparam BYTES = 1024;
    (* ram_style = "block" *)
    reg [7:0] mem [0:BYTES-1];

    integer i;
    initial begin
        for (i = 0; i < BYTES; i = i + 1) mem[i] = 8'h00;
    end

    // write (synchronous) - handle byte/half/word
    always @(posedge clk) begin
        if (we) begin
            case (size)
                2'b00: begin // byte
                    mem[addr] <= wdata[7:0];
                end
                2'b01: begin // halfword (2 bytes) - align by addr[0]
                    if (addr[0] == 1'b0) begin
                        mem[addr]     <= wdata[7:0];
                        mem[addr+1]   <= wdata[15:8];
                    end else begin
                        // unaligned half - store into addr and addr+1 (still works)
                        mem[addr]     <= wdata[7:0];
                        mem[addr+1]   <= wdata[15:8];
                    end
                end
                2'b10: begin // word (4 bytes) - little endian
                    mem[addr]     <= wdata[7:0];
                    mem[addr+1]   <= wdata[15:8];
                    mem[addr+2]   <= wdata[23:16];
                    mem[addr+3]   <= wdata[31:24];
                end
                default: begin
                    mem[addr] <= wdata[7:0];
                end
            endcase
        end
        // read word-aligned (assemble little-endian) - registered output
        rdata <= { mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr] };
    end

endmodule

`endif
