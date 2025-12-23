`timescale 1ns / 1ps
`ifndef MISIRI_IMEM_V
`define MISIRI_IMEM_V

// -----------------------------------------------------------------------------
// imem.v
// IMEM: ROM de instrucciones word-aligned.
// - Address: byte address (pc), pero internamente indexamos por [11:2]
// - Depth: 2048 words (8192 bytes)
// - Lectura síncrona: rdata sale en siguiente flanco.
// - Inicialización por initial / $readmemh.
// -----------------------------------------------------------------------------

module imem (
    input  wire        clk,
    input  wire [31:0] addr,   // byte address (PC)
    output reg  [31:0] rdata
);

    localparam WORDS = 2048;
    reg [31:0] mem [0:WORDS-1];

    integer i;
    initial begin
        // inicializar a NOP (ADDI x0,x0,0 = 0x00000013)
        for (i = 0; i < WORDS; i = i + 1) mem[i] = 32'h00000013;

        // Programa de prueba (puedes comentar y usar $readmemh)
        mem[0] = 32'h00500093; // ADDI x1, x0, 5
        mem[1] = 32'h00A00113; // ADDI x2, x0, 10
        mem[2] = 32'h002081B3; // ADD x3, x1, x2
        mem[3] = 32'hFFD00213; // ADDI x4, x0, -3
        mem[4] = 32'h001222B3; // SLT x5, x4, x1
        mem[5] = 32'h0100006F; // JAL x0, 8
        mem[6] = 32'h00100313; // ADDI x6, x0, 1
        mem[7] = 32'h00200393; // ADDI x7, x0, 2
        mem[8] = 32'h007C0433; // ADD x8, x6, x7
    end

    // lectura síncrona: index por word address addr[11:2]
    wire [10:0] idx = addr[11:2]; // 2048 words -> 11 bits
    always @(posedge clk) begin
        if (idx < WORDS)
            rdata <= mem[idx];
        else
            rdata <= 32'h00000013; // NOP si fuera fuera de rango
    end

endmodule

`endif
