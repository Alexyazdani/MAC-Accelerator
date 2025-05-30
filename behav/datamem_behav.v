module datamem (
    input         clk,
    input  [5:0]  waddr,
    input  [5:0]  raddr,
    input  [15:0] din,
    input         wea,
    output reg [15:0] dout
);
    reg [15:0] mem [63:0];

    always @(posedge clk) begin
        if (wea) mem[waddr] <= din;
    end
    always @(posedge clk) begin
        dout <= mem[raddr];
    end
endmodule

module datamem_512 (
    input         clk,
    input  [8:0]  waddr,
    input  [8:0]  raddr,
    input  [15:0] din,
    input         wea,
    output [15:0] dout
);
    wire [15:0] dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7;
    wire [2:0] wsel = waddr[8:6];
    wire [2:0] rsel = raddr[8:6];
    wire [5:0] local_waddr = waddr[5:0];
    wire [5:0] local_raddr = raddr[5:0];

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
        ( rsel_reg[2] &  rsel_reg[1] &  rsel_reg[0]) ? dout7 : 16'b0;

    datamem mem0 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea & ~wsel[2] & ~wsel[1] & ~wsel[0]), .dout(dout0));
    datamem mem1 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea & ~wsel[2] & ~wsel[1] &  wsel[0]), .dout(dout1));
    datamem mem2 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea & ~wsel[2] &  wsel[1] & ~wsel[0]), .dout(dout2));
    datamem mem3 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea & ~wsel[2] &  wsel[1] &  wsel[0]), .dout(dout3));
    datamem mem4 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea &  wsel[2] & ~wsel[1] & ~wsel[0]), .dout(dout4));
    datamem mem5 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea &  wsel[2] & ~wsel[1] &  wsel[0]), .dout(dout5));
    datamem mem6 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea &  wsel[2] &  wsel[1] & ~wsel[0]), .dout(dout6));
    datamem mem7 (.clk(clk), .waddr(local_waddr), .raddr(local_raddr), .din(din), .wea(wea &  wsel[2] &  wsel[1] &  wsel[0]), .dout(dout7));

endmodule

// module datamem_512 (
//     input         clk,
//     input  [8:0]  waddr,
//     input  [8:0]  raddr,
//     input  [15:0] din,
//     input         wea,
//     output reg [15:0] dout
// );
//     reg [15:0] mem [511:0];

//     always @(posedge clk) begin
//         if (wea) mem[waddr] <= din;
//     end
//     always @(posedge clk) begin
//         dout <= mem[raddr];
//     end
// endmodule