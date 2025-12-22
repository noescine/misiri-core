`timescale 1ns / 1ps

module Control_unit(
    input prog_mode,
    input RESET,               // Señal de reset para inicializar en 0
    input [6:0] OpCode,        // 7 bits de OpCode (indicador de la instrucción)
    input [2:0] Funct3,        // 3 bits de Funct3
    input [6:0] Funct7,        // 7 bits de Funct7
    output reg [2:0] ImmSrc,   // Determina qué tipo de inmediato
    output reg ALUASrc,        // Si el operando A es un inmediato
    output reg ALUBSrc,        // Si el operando B es un inmediato
    output reg [3:0] ALUOp,    // Operación para la ALU (suma, resta, etc.)
    output reg [1:0] RUDataWrSrc, // Fuente de datos para escritura en registros
    output reg RUWr,           // Habilita la escritura en el banco de registros
    output reg [4:0] BrOp      // Controla las operaciones de salto y rama
);

// Ejecutar la lógica en cada flanco de subida del reloj o cuando RESET sea activado
always @(*) begin
        // Reinicialización de señales en reset
    if(RESET | prog_mode )begin
        ImmSrc <= 3'b000;
        ALUASrc <= 1'b0;
        ALUBSrc <= 1'b0;
        ALUOp <= 4'b0000;
        RUDataWrSrc <= 2'b00;
        RUWr <= 1'b0;
        BrOp <= 5'b00000;
    end     
        // Lógica de control en flanco positivo del reloj
        case (OpCode)
            7'b0110011: begin // Tipo R (Instrucciones aritméticas)
                ImmSrc <= 3'b000;
                ALUASrc <= 1'b0;
                ALUBSrc <= 1'b0;
                ALUOp <= {Funct7[6], Funct3}; 
                RUDataWrSrc <= 2'b00;
                RUWr <= 1'b1;
                BrOp <= 5'b00000;
            end

            7'b0010011: begin // Tipo I (Operaciones aritméticas con inmediato)
                ImmSrc <= 3'b000;
                ALUASrc <= 1'b0;
                ALUBSrc <= 1'b1;
                ALUOp <= {Funct7[6], Funct3};
                RUDataWrSrc <= 2'b00;
                RUWr <= 1'b1;
                BrOp <= 5'b00000;
            end

            7'b1100011: begin // Tipo B (Saltos condicionales)
                ImmSrc <= 3'b101;
                ALUASrc <= 1'b1;
                ALUBSrc <= 1'b1;
                ALUOp <= 4'b0000;
                RUDataWrSrc <= 2'b00;
                RUWr <= 1'b0;
                BrOp <= {2'b01, Funct3};
            end

            7'b0000011: begin // Tipo I (Carga)
                ImmSrc <= 3'b000;
                ALUASrc <= 1'b0;
                ALUBSrc <= 1'b1;
                ALUOp <= 4'b0000; // Suma para calcular dirección
                RUDataWrSrc <= 2'b01;
                RUWr <= 1'b1;
                BrOp <= 5'b00000;
            end

            7'b0100011: begin // Tipo S (Almacenamiento)
                ImmSrc <= 3'b001;
                ALUASrc <= 1'b0;
                ALUBSrc <= 1'b1;
                ALUOp <= 4'b0000;
                RUDataWrSrc <= 2'b00;
                RUWr <= 1'b0;
                BrOp <= 5'b00000;
            end

            7'b0110111: begin // LUI
                ImmSrc <= 3'b010;
                ALUASrc <= 1'b0;
                ALUBSrc <= 1'b1;
                ALUOp <= 4'b1111; // Lógica para LUI
                RUDataWrSrc <= 2'b00;
                RUWr <= 1'b1;
                BrOp <= 5'b00000;
            end

            7'b0010111: begin // AUIPC (Carga inmediato de 20 bits + PC)
                ImmSrc <= 3'b010;
                ALUASrc <= 1'b1;
                ALUBSrc <= 1'b0;
                ALUOp <= 4'b0000;
                RUDataWrSrc <= 2'b10;
                RUWr <= 1'b1;
                BrOp <= 5'b00000;
            end

            7'b1101111: begin // JAL
                ImmSrc <= 3'b110;
                ALUASrc <= 1'b1;
                ALUBSrc <= 1'b1;
                ALUOp <= 4'b0000;
                RUDataWrSrc <= 2'b10;
                RUWr <= 1'b1;
                BrOp <= 5'b10000;
            end

            7'b1100111: begin // Tipo I (JALR)
                ImmSrc <= 3'b000;
                ALUASrc <= 1'b0;
                ALUBSrc <= 1'b1;
                ALUOp <= 4'b0000;
                RUDataWrSrc <= 2'b10;
                RUWr <= 1'b1;
                BrOp <= 5'b10000;
            end

            default: begin // Valores por defecto (por si el OpCode no es reconocido)
                ImmSrc <= 3'b000;
                ALUASrc <= 1'b0;
                ALUBSrc <= 1'b0;
                ALUOp <= 4'b0000;
                RUDataWrSrc <= 2'b00;
                RUWr <= 1'b0;
                BrOp <= 5'b00000;
            end
        endcase
    end


endmodule
