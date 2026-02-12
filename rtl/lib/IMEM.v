`timescale 1ns / 1ps
`ifndef MISIRI_IMEM_V
`define MISIRI_IMEM_V

// IMEM: ROM de instrucciones (word-aligned)
// - Depth: 2048 words
// - Address: byte address, usamos bits [11:2] para index (word aligned)

module imem (
    input  wire        clk,
    input  wire [31:0] addr,   // byte address
    output reg  [31:0] rdata
);
    localparam WORDS = 2048;
    (* ram_style = "block" *)
    reg [31:0] mem [0:WORDS-1];

    integer i;
    initial begin
        // Inicializa todo a NOP
        for (i = 0; i < WORDS; i = i + 1) mem[i] = 32'h00000013; // NOP ADDI x0,x0,0

        // Programa de prueba ampliado (ejemplo). Puedes sustituir por $readmemh.
        mem[0] = 32'h00500093; // ADDI x1, x0, 5
        mem[1] = 32'h00A00113; // ADDI x2, x0, 10
        mem[2] = 32'h002081B3; // ADD x3, x1, x2
        mem[3] = 32'hFFD00213; // ADDI x4, x0, -3
        mem[4] = 32'h001222B3; // SLT x5, x4, x1
        mem[5] = 32'h0100006F; // JAL x0, 8
        mem[6] = 32'h00100313; // ADDI x6, x0, 1
        mem[7] = 32'h00200393; // ADDI x7, x0, 2
        mem[8] = 32'h007C0433; // ADD x8, x6, x7
        // ejemplo extendido: utiliza direcciones siguientes para cubrir más instrucciones
        mem[9]  = 32'h00000413; // ADDI x8, x0, 0 (ejemplo)
        mem[10] = 32'h00000513; // ADDI x10,x0,0
        // ... añade más si quieres
    end

    // lectura registrada: rdata disponible al siguiente flanco
    always @(posedge clk) begin
        rdata <= mem[addr[11:2]]; // word index
    end

endmodule

`endif
