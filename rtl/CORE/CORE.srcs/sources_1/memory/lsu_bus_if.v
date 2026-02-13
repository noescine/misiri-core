module lsu_bus_if (
    input  wire [31:0] addr_base,
    input  wire [31:0] store_data,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [1:0]  mem_size,
    input  wire [1:0]  addr_lsb,
    output reg  [31:0] d_addr,
    output reg  [31:0] d_wdata,
    output reg  [3:0]  d_we,
    output reg         d_req
);

    always @(*) begin
        d_addr  = addr_base;
        d_wdata = store_data;
        d_req   = mem_read | mem_write;

        // Generación de byte enables según tamaño y alineación
        d_we = 4'b0000;
        if (mem_write) begin
            case (mem_size)
                2'b00: d_we = 4'b0001 << addr_lsb;        // byte
                2'b01: d_we = (addr_lsb[1]) ? 4'b1100 : 4'b0011; // half
                2'b10: d_we = 4'b1111;                   // word
                default: d_we = 4'b0000;
            endcase
        end
    end

endmodule