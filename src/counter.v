/*
counter.v
Program Counter for 5-stage pipeline for ARMv8-M architecture

Engineer: Alexander Yazdani
Engineer: Szymon Gorski
Engineer: Tim Lu

University of Southern California (USC)
EE533 - Spring 2025
Professor Young Cho
25 February 2025
*/

module counter12b (
    input wire clk,
    input wire reset,
    input wire pipe_en,
    input wire [11:0] in,
    input wire load_en,
    input wire [11:0] load,
    output reg [11:0] out
);
    wire [11:0] sum;
    wire [11:0] carry;

    half_adder ha0 (.a(in[0]), .b(1'b1),     .sum(sum[0]), .cout(carry[0]));
    half_adder ha1 (.a(in[1]), .b(carry[0]), .sum(sum[1]), .cout(carry[1]));
    half_adder ha2 (.a(in[2]), .b(carry[1]), .sum(sum[2]), .cout(carry[2]));
    half_adder ha3 (.a(in[3]), .b(carry[2]), .sum(sum[3]), .cout(carry[3]));
    half_adder ha4 (.a(in[4]), .b(carry[3]), .sum(sum[4]), .cout(carry[4]));
    half_adder ha5 (.a(in[5]), .b(carry[4]), .sum(sum[5]), .cout(carry[5]));
    half_adder ha6 (.a(in[6]), .b(carry[5]), .sum(sum[6]), .cout(carry[6]));
    half_adder ha7 (.a(in[7]), .b(carry[6]), .sum(sum[7]), .cout(carry[7]));
    half_adder ha8 (.a(in[8]), .b(carry[7]), .sum(sum[8]), .cout(carry[8]));
    half_adder ha9 (.a(in[9]), .b(carry[8]), .sum(sum[9]), .cout(carry[9]));
    half_adder ha10 (.a(in[10]), .b(carry[9]), .sum(sum[10]), .cout(carry[10]));
    half_adder ha11 (.a(in[11]), .b(carry[10]), .sum(sum[11]), .cout(carry[11]));


    always @(posedge clk) begin
        if (reset) 
            out <= 12'b0;
        else if (load_en) 
            out <= load;
        else if (pipe_en) 
            out <= sum;
    end
endmodule

module counter9b (
    input wire clk,
    input wire reset,
    input wire pipe_en,
    input wire [8:0] in,
    input wire load_en,
    input wire [8:0] load,
    output reg [8:0] out
);
    wire [8:0] sum;
    wire [8:0] carry;

    half_adder ha0 (.a(in[0]), .b(1'b1),     .sum(sum[0]), .cout(carry[0]));
    half_adder ha1 (.a(in[1]), .b(carry[0]), .sum(sum[1]), .cout(carry[1]));
    half_adder ha2 (.a(in[2]), .b(carry[1]), .sum(sum[2]), .cout(carry[2]));
    half_adder ha3 (.a(in[3]), .b(carry[2]), .sum(sum[3]), .cout(carry[3]));
    half_adder ha4 (.a(in[4]), .b(carry[3]), .sum(sum[4]), .cout(carry[4]));
    half_adder ha5 (.a(in[5]), .b(carry[4]), .sum(sum[5]), .cout(carry[5]));
    half_adder ha6 (.a(in[6]), .b(carry[5]), .sum(sum[6]), .cout(carry[6]));
    half_adder ha7 (.a(in[7]), .b(carry[6]), .sum(sum[7]), .cout(carry[7]));
    half_adder ha8 (.a(in[8]), .b(carry[7]), .sum(sum[8]), .cout(carry[8]));

    always @(posedge clk) begin
        if (reset) 
            out <= 9'b0;
        else if (load_en) 
            out <= load;
        else if (pipe_en) 
            out <= sum;
    end
endmodule

module counter6b (
    input wire clk,
    input wire reset,
    input wire pipe_en,
    input wire [5:0] in,
    input wire load_en,
    input wire [5:0] load,
    output reg [5:0] out
);
    wire [5:0] sum;
    wire [5:0] carry;

    half_adder ha0 (.a(in[0]), .b(1'b1),     .sum(sum[0]), .cout(carry[0]));
    half_adder ha1 (.a(in[1]), .b(carry[0]), .sum(sum[1]), .cout(carry[1]));
    half_adder ha2 (.a(in[2]), .b(carry[1]), .sum(sum[2]), .cout(carry[2]));
    half_adder ha3 (.a(in[3]), .b(carry[2]), .sum(sum[3]), .cout(carry[3]));
    half_adder ha4 (.a(in[4]), .b(carry[3]), .sum(sum[4]), .cout(carry[4]));
    half_adder ha5 (.a(in[5]), .b(carry[4]), .sum(sum[5]), .cout(carry[5]));

    always @(posedge clk) begin
        if (reset) 
            out <= 6'b0;
        else if (load_en) 
            out <= load;
        else if (pipe_en) 
            out <= sum;
    end
endmodule

module half_adder (
    input wire a,    
    input wire b,    
    output wire sum,  
    output wire cout  
);
    assign sum = a ^ b;
    assign cout = a & b;
endmodule