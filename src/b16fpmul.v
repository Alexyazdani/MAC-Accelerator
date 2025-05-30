/*
Alexander Yazdani
University of Southern California
EE533
6 April 2025

BFLOAT16 Multiplier Module - b16fpmul
16-bit Floating Point Multiplier
*/

module b16fpmul (oprA, oprB, Result);        // Custom FP16 Multiplier with 10-bit mantissa and 5-bit exponent

    input [15:0] oprA, oprB;
    output reg [15:0] Result;

    reg SA, SB, SR;                 // Sign bits
    reg [4:0] ExpA, ExpB, ExpR;     // Exponents
    reg [5:0] ExpZ;
    reg [9:0] FracA, FracB, FracR;  // Input / Output Fractions
    reg [21:0] FracZ;               // Intermediate Fraction

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
        ExpZ = ExpA[4:0] + ExpB[4:0];
        ExpZ = ExpZ - 15;

        // Normalize
        ExpR = FracZ[21] ? ExpZ + 1 : ExpZ;
        FracR = FracZ[21] ? FracZ[20:11] : FracZ[19:10];

        // Format and assign the result
        
        Result = ExpZ[5] ? 16'b0 : {SR, ExpR[4:0], FracR};

    end
endmodule

// module b16fpmul (oprA, oprB, Result);       // BFLOAT16 Multiplier

//     input [15:0] oprA, oprB;
//     output reg [15:0] Result;

//     reg SA, SB, SR;                 // Sign bits
//     reg [7:0] ExpA, ExpB;           // Exponents
//     reg [9:0] ExpR;
//     reg [6:0] FracA, FracB, FracR;  // Input / Output Fractions
//     reg [15:0] FracZ;               // Intermediate Fraction

//     always @(*) begin

//         // Parse the inputs for sign, exponent, and fraction
//         SA = oprA[15];
//         SB = oprB[15];
//         ExpA = oprA[14:7];
//         ExpB = oprB[14:7];
//         FracA = oprA[6:0];
//         FracB = oprB[6:0]; 

//         // XOR the sign bits to find the final sign bit
//         SR = SA ^ SB;

//         // Multiply the fractions
//         FracZ = {1'b1, FracA} * {1'b1, FracB};

//         // Add the exponents and subtract 127
//         ExpR = ExpA + ExpB;
//         ExpR = ExpR - 127;

//         // Normalize
//         ExpR = FracZ[15] ? ExpR + 1 : ExpR;
//         // ExpR = ExpR[8] ? ExpR[8:1] : ExpR[7:0];
//         FracR = FracZ[15] ? FracZ[14:8] : FracZ[13:7];

//         // Format and assign the result
//         Result = {SR, ExpR[7:0], FracR[6:0]};

//     end
// endmodule
