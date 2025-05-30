/*
Alexander Yazdani
University of Southern California
EE533
6 April 2025

BFLOAT16 Adder Module - b16fpmul
16-bit Floating Point Adder
*/

module b16fpadd_pipe (oprA, oprB, clk, reset, pipe_en, Result);        // Custom FP16 Adder with 10-bit mantissa and 5-bit exponent

    input [15:0] oprA, oprB;
    input clk, reset, pipe_en;
    output reg [15:0] Result;

    reg SA, SB, SR;                 // Sign bits
    reg [4:0] ExpA, ExpB, ExpR;     // Exponents
    reg [9:0] FracA, FracB, FracR;  // Input / Output Fractions
    reg [11:0] FracA_ext, FracB_ext; // Extended fractions
    reg [12:0] FracZ;
    reg [4:0] ExpDiff;
    integer i;
    reg [3:0] shift_amt;

    always @(*) begin
        SA = oprA[15];
        SB = oprB[15];
        ExpA = oprA[14:10];
        ExpB = oprB[14:10];
        FracA = oprA[9:0];
        FracB = oprB[9:0];
        FracA_ext = (ExpA == 0) ? {1'b0, FracA, 1'b0} : {1'b1, FracA, 1'b0};  // 12 bits
        FracB_ext = (ExpB == 0) ? {1'b0, FracB, 1'b0} : {1'b1, FracB, 1'b0};  // 12 bits
        if (ExpA > ExpB) begin
            ExpDiff = ExpA - ExpB;
            FracB_ext = FracB_ext >> ExpDiff;
            ExpR = ExpA;
        end else begin
            ExpDiff = ExpB - ExpA;
            FracA_ext = FracA_ext >> ExpDiff;
            ExpR = ExpB;
        end

        if (SA == SB) begin
            FracZ = FracA_ext + FracB_ext;
            SR = SA;
        end else begin
            if (FracA_ext >= FracB_ext) begin
                FracZ = FracA_ext - FracB_ext;
                SR = SA;
            end else begin
                FracZ = FracB_ext - FracA_ext;
                SR = SB;
            end
        end
    end 

    reg [4:0] ExpR_reg;
    // reg [9:0] FracR_reg;
    reg [12:0] FracZ_reg;
    reg SR_reg;
    always @(posedge clk) begin
        if (reset) begin
            ExpR_reg <= 0;
            // FracR_reg <= 0;
            FracZ_reg <= 0;
            SR_reg <= 0;
        end else if (pipe_en) begin
            ExpR_reg <= ExpR;
            // FracR_reg <= FracR;
            FracZ_reg <= FracZ;
            SR_reg <= SR;
        end
    end
    reg [4:0] ExpR_norm;
    reg [9:0] FracR_norm;
    reg [12:0] FracZ_norm;
    reg SR_norm;

    always @(*) begin
        if (FracZ_reg == 0) begin
            ExpR_norm = 0;
            FracR_norm = 0;
            SR_norm = 0;
        end else begin
            casex (FracZ_reg)
                13'b1xxxxxxxxxxxx: shift_amt = 0;
                13'b01xxxxxxxxxxx: shift_amt = 1;
                13'b001xxxxxxxxxx: shift_amt = 2;
                13'b0001xxxxxxxxx: shift_amt = 3;
                13'b00001xxxxxxxx: shift_amt = 4;
                13'b000001xxxxxxx: shift_amt = 5;
                13'b0000001xxxxxx: shift_amt = 6;
                13'b00000001xxxxx: shift_amt = 7;
                13'b000000001xxxx: shift_amt = 8;
                13'b0000000001xxx: shift_amt = 9;
                13'b00000000001xx: shift_amt = 10;
                13'b000000000001x: shift_amt = 11;
                13'b0000000000001: shift_amt = 12;
                default: shift_amt = 13;
            endcase
            FracZ_norm = FracZ_reg << shift_amt;
            ExpR_norm = ExpR_reg - shift_amt + 1;
            FracR_norm = FracZ_norm[11:2];
            SR_norm = SR_reg;
        end
        Result = {SR_norm, ExpR_norm, FracR_norm};
        // Result = 16'b0;
    end
endmodule
