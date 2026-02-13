module lsu_align (
    input  wire [31:0] mem_word,
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

        // ---------- LOAD (alineación y extensión) ----------
        if (is_load) begin
            case (mem_size)
                2'b00: begin // byte
                    case (addr_lsb)
                        2'b00: load_data = mem_signed ? {{24{mem_word[7]}},  mem_word[7:0]}   : {24'd0, mem_word[7:0]};
                        2'b01: load_data = mem_signed ? {{24{mem_word[15]}}, mem_word[15:8]}  : {24'd0, mem_word[15:8]};
                        2'b10: load_data = mem_signed ? {{24{mem_word[23]}}, mem_word[23:16]} : {24'd0, mem_word[23:16]};
                        2'b11: load_data = mem_signed ? {{24{mem_word[31]}}, mem_word[31:24]} : {24'd0, mem_word[31:24]};
                    endcase
                end
                2'b01: begin // half
                    if (addr_lsb[1] == 1'b0)
                        load_data = mem_signed ? {{16{mem_word[15]}}, mem_word[15:0]} : {16'd0, mem_word[15:0]};
                    else
                        load_data = mem_signed ? {{16{mem_word[31]}}, mem_word[31:16]} : {16'd0, mem_word[31:16]};
                end
                2'b10: begin // word
                    load_data = mem_word;
                end
                default: load_data = mem_word;
            endcase
        end

        // ---------- STORE (formateo: desplazar dato a la posición correcta) ----------
        if (is_store) begin
            case (mem_size)
                2'b00: begin // byte
                    store_data = rs2_data[7:0] << {addr_lsb, 3'b0}; // desplazamiento 0,8,16,24
                end
                2'b01: begin // half
                    if (addr_lsb[1])
                        store_data = rs2_data[15:0] << 16;
                    else
                        store_data = rs2_data[15:0];  // bits 15:0
                end
                2'b10: begin // word
                    store_data = rs2_data;
                end
                default: store_data = rs2_data;
            endcase
        end
    end
endmodule