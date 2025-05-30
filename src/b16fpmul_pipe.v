/*
Alexander Yazdani
University of Southern California
EE533
6 April 2025

BFLOAT16 Multiplier Module - b16fpmul
16-bit Floating Point Multiplier
*/

module b16fpmul_pipe (         // Custom FP16 Multiplier with 10-bit mantissa and 5-bit exponent
    input [15:0] oprA, oprB,
    input clk,
    input rst,
    output reg [15:0] Result
);    

    reg SA, SB, SR;                 // Sign bits
    reg [5:0] ExpZ; 
    reg [4:0] ExpA, ExpB, ExpR;     // Exponents
    reg [9:0] FracA, FracB, FracR;  // Input / Output Fractions
    reg [21:0] FracZ;               // Intermediate Fraction

    reg [21:0] FracZ_reg;
    reg [5:0] ExpR_reg;
    reg SRreg; 

    always @(*) begin

        // Parse the inputs for sign, exponent, and fraction
        SA = oprA[15];
        SB = oprB[15];
        ExpA = oprA[14:10];
        ExpB = oprB[14:10];
        FracA = oprA[9:0];
        FracB = oprB[9:0]; 

        // XOR the sign bits to find the final sign bit
        SR = SA ^ SB;

        // Multiply the fractions
        FracZ = {1'b1, FracA} * {1'b1, FracB};

        // Add the exponents and subtract 15
        ExpZ = ExpA + ExpB;
        ExpZ = ExpZ - 15;
    end

    always @(posedge clk) begin
        // Store intermediate results
        if (rst) begin
            FracZ_reg <= 0;
            ExpR_reg <= 0;
            SRreg <= 0;
        end else begin
            FracZ_reg <= FracZ;
            ExpR_reg <= ExpZ[5:0];
            SRreg <= SR;
        end
    end

    reg [4:0] ExpR_out;

    always @(*) begin
        // Normalize
        ExpR_out = FracZ_reg[21] ? ExpR_reg[4:0] + 1 : ExpR_reg[4:0];
        FracR = FracZ_reg[21] ? FracZ_reg[20:11] : FracZ_reg[19:10];

        // Format and assign the result
        // Result = {SRreg, ExpR_out[4:0], FracR};
        if (ExpR_reg[5] == 1) begin
            Result = 16'b0;
        end else begin
            Result = {SRreg, ExpR_out[4:0], FracR};
        end

    end
endmodule

