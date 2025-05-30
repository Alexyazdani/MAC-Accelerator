////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : datamem.vf
// /___/   /\     Timestamp : 04/18/2025 14:26:27
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family virtex2p -w "C:/Documents and Settings/student/mem16/datamem.sch" datamem.vf
//Design Name: datamem
//Device: virtex2p
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module datamem(clk, 
               din, 
               raddr, 
               waddr, 
               wea, 
               dout);

    input clk;
    input [15:0] din;
    input [5:0] raddr;
    input [5:0] waddr;
    input wea;
   output [15:0] dout;
   
   
   mem16 XLXI_1 (.addra(waddr[5:0]), 
                 .addrb(raddr[5:0]), 
                 .clka(clk), 
                 .clkb(clk), 
                 .dina(din[15:0]), 
                 .wea(wea), 
                 .doutb(dout[15:0]));
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
