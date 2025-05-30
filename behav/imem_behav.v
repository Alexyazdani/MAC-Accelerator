module imem (
    input  [8:0]  addr,
    input  [31:0] din,
    input         clk,
    input         we,
    output reg [31:0] dout
);
    reg [31:0] mem [511:0];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        dout <= mem[addr];
    end
endmodule

module imem_4096 (
    input         clk,
    input  [11:0] addr,
    input  [31:0] din,
    input         we,
    output [31:0] dout
);
    wire [31:0] dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7;
    wire [2:0] wsel = addr[11:9];
    wire [2:0] rsel = addr[11:9];
    wire [8:0] local_addr = addr[8:0];

    reg [2:0] rsel_reg;
    always @(posedge clk) begin
        rsel_reg <= rsel;
    end

    assign dout =
        (~rsel_reg[2] & ~rsel_reg[1] & ~rsel_reg[0]) ? dout0 :
        (~rsel_reg[2] & ~rsel_reg[1] &  rsel_reg[0]) ? dout1 :
        (~rsel_reg[2] &  rsel_reg[1] & ~rsel_reg[0]) ? dout2 :
        (~rsel_reg[2] &  rsel_reg[1] &  rsel_reg[0]) ? dout3 :
        ( rsel_reg[2] & ~rsel_reg[1] & ~rsel_reg[0]) ? dout4 :
        ( rsel_reg[2] & ~rsel_reg[1] &  rsel_reg[0]) ? dout5 :
        ( rsel_reg[2] &  rsel_reg[1] & ~rsel_reg[0]) ? dout6 :
        ( rsel_reg[2] &  rsel_reg[1] &  rsel_reg[0]) ? dout7 : 32'b0;

    imem mem0 (.clk(clk), .addr(local_addr), .din(din), .we(we & ~wsel[2] & ~wsel[1] & ~wsel[0]), .dout(dout0));
    imem mem1 (.clk(clk), .addr(local_addr), .din(din), .we(we & ~wsel[2] & ~wsel[1] &  wsel[0]), .dout(dout1));
    imem mem2 (.clk(clk), .addr(local_addr), .din(din), .we(we & ~wsel[2] &  wsel[1] & ~wsel[0]), .dout(dout2));
    imem mem3 (.clk(clk), .addr(local_addr), .din(din), .we(we & ~wsel[2] &  wsel[1] &  wsel[0]), .dout(dout3));
    imem mem4 (.clk(clk), .addr(local_addr), .din(din), .we(we &  wsel[2] & ~wsel[1] & ~wsel[0]), .dout(dout4));
    imem mem5 (.clk(clk), .addr(local_addr), .din(din), .we(we &  wsel[2] & ~wsel[1] &  wsel[0]), .dout(dout5));
    imem mem6 (.clk(clk), .addr(local_addr), .din(din), .we(we &  wsel[2] &  wsel[1] & ~wsel[0]), .dout(dout6));
    imem mem7 (.clk(clk), .addr(local_addr), .din(din), .we(we &  wsel[2] &  wsel[1] &  wsel[0]), .dout(dout7));

endmodule


// module imem_4096 (
//     input  [11:0]  addr,
//     input  [31:0] din,
//     input         clk,
//     input         we,
//     output reg [31:0] dout
// );
//     reg [31:0] mem [4095:0];

//     always @(posedge clk) begin
//         if (we)
//             mem[addr] <= din;
//         dout <= mem[addr];
//     end
// endmodule



