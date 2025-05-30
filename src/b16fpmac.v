// /*
// Alexander Yazdani  
// University of Southern California  
// EE533  
// 9 April 2025  

// BFLOAT16 MAC Module - b16fpmac  
// 16-bit Floating Point Multiply-Accumulate
// */

module b16fpmac (
    input clk,
    input rst,
    input valid,
    input [15:0] oprA,
    input [15:0] oprB,
    output reg [15:0] Result
);

    reg [15:0] sum_reg;
    wire [15:0] mul_result;
    wire [15:0] add_result;
    reg [15:0] im_result;
    reg im_valid;

    b16fpmul mul (.oprA(oprA), .oprB(oprB), .Result(mul_result));
    b16fpadd add (.oprA(sum_reg), .oprB(im_result), .Result(add_result));

    always @(posedge clk) begin
        if (rst) begin
            sum_reg <= 16'h0000;
        end else if (im_valid) begin
            sum_reg <= add_result;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            im_valid <= 0;
            im_result <= 16'h0000;
        end else begin
            im_valid <= valid;
            im_result <= mul_result;
        end
        Result <= sum_reg;
    end


endmodule


// module b16fpmac (
//     input clk,
//     input rst,
//     input valid,
//     input [15:0] oprA,
//     input [15:0] oprB,
//     output reg [15:0] Result
// );

//     reg [15:0] sum_reg;
//     wire [15:0] mul_result;
//     wire [15:0] add_result;

//     b16fpmul mul (.oprA(oprA), .oprB(oprB), .Result(mul_result));
//     b16fpadd add (.oprA(sum_reg), .oprB(mul_result), .Result(add_result));

//     always @(posedge clk) begin
//         if (rst)
//             sum_reg <= 16'h0000;
//         else if (valid)
//             sum_reg <= add_result;

//         Result <= sum_reg;
//     end

// endmodule
