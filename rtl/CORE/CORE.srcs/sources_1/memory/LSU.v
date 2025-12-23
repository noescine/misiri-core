`timescale 1ns / 1ps
`ifndef MISIRI_LSU_V
`define MISIRI_LSU_V

// -----------------------------------------------------------------------------
// LSU.v
// - mem_word: palabra leída desde DMEM (word bread), pero en nuestro diseño
//   dmem devuelve la palabra a partir de la dirección byte indicada.
// - rs2_data: valor a escribir (store) tomado del regfile.
// - addr_lsb: alu_result[1:0]  (offset dentro de la palabra)
// - mem_size: 00=byte,01=half,10=word
// - mem_signed: si la carga es signed (LB/LH) o no (LBU/LHU)
// - is_load/is_store: control
// - load_data: dato final para writeback (32 bits)
// - store_data: palabra alineada para escribir en DMEM (wdata)
// -----------------------------------------------------------------------------

module LSU (
    input  wire [31:0] mem_word,   // palabra cruda leída desde DMEM (la que empieza en addr)
    input  wire [31:0] rs2_data,
    input  wire [1:0]  addr_lsb,
    input  wire [1:0]  mem_size,
    input  wire        mem_signed,
    input  wire        is_load,
    input  wire        is_store,

    output reg  [31:0] load_data,
    output reg  [31:0] store_data
);

    always @(*) begin
        load_data  = 32'd0;
        store_data = 32'd0;

        // LOAD path
        if (is_load) begin
            case (mem_size)
                2'b00: begin // BYTE
                    case (addr_lsb)
                        2'b00: load_data = mem_signed ? {{24{mem_word[7]}},  mem_word[7:0]}   : {24'd0, mem_word[7:0]};
                        2'b01: load_data = mem_signed ? {{24{mem_word[15]}}, mem_word[15:8]}  : {24'd0, mem_word[15:8]};
                        2'b10: load_data = mem_signed ? {{24{mem_word[23]}}, mem_word[23:16]} : {24'd0, mem_word[23:16]};
                        2'b11: load_data = mem_signed ? {{24{mem_word[31]}}, mem_word[31:24]} : {24'd0, mem_word[31:24]};
                    endcase
                end
                2'b01: begin // HALF
                    if (addr_lsb[1] == 1'b0)
                        load_data = mem_signed ? {{16{mem_word[15]}}, mem_word[15:0]} : {16'd0, mem_word[15:0]};
                    else
                        load_data = mem_signed ? {{16{mem_word[31]}}, mem_word[31:16]} : {16'd0, mem_word[31:16]};
                end
                2'b10: begin // WORD
                    load_data = mem_word;
                end
                default: load_data = mem_word;
            endcase
        end

        // STORE path (produces store_data: full word little-endian assembled from rs2_data
        // We write entire word; memory_controller/dmem will use we + size to write bytes properly.
        if (is_store) begin
            // store_data is rs2_data as-is (little-endian when dmem writes by bytes)
            store_data = rs2_data;
        end
    end

endmodule

`endif
