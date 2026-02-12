module pc_reg #(
    parameter RESET_VECTOR = 32'h00000000
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        pc_en,
    input  wire [31:0] pc_next,
    input  wire [31:0] boot_pc,      // Nuevo: valor de reset
    output reg  [31:0] pc
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= boot_pc;
        else if (pc_en)
            pc <= pc_next;
    end
endmodule