/*
Alexander Yazdani
University of Southern California
EE533
6 April 2025

BFLOAT16 Adder Module - b16fpmul
16-bit Floating Point Adder
*/




module b16fpadd (oprA, oprB, Result);        // Custom FP16 Adder with 10-bit mantissa and 5-bit exponent

    input [15:0] oprA, oprB;
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
        if (FracZ == 0) begin
            ExpR = 0;
            FracR = 0;
            SR = 0;
        end else begin
            casex (FracZ)
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
            FracZ = FracZ << shift_amt;
            ExpR = ExpR - shift_amt + 1;
            FracR = FracZ[11:2];
        end
        Result = {SR, ExpR, FracR};
    end
endmodule

// module b16fpadd (oprA, oprB, Result);       // BFLOAT16 Adder Module

//     input [15:0] oprA, oprB;
//     output reg [15:0] Result;
//     reg SA, SB, SR;                 // Sign bits
//     reg [7:0] ExpA, ExpB, ExpR;     // Exponents
//     reg [6:0] FracA, FracB, FracR;  // Input / Output Fractions
//     reg [8:0] FracA_ext, FracB_ext; // Extended fractions
//     reg [9:0] FracZ;
//     reg [7:0] ExpDiff;
//     integer i;
//     reg [3:0] shift_amt;
//     always @(*) begin
//         SA = oprA[15];
//         SB = oprB[15];
//         ExpA = oprA[14:7];
//         ExpB = oprB[14:7];
//         FracA = oprA[6:0];
//         FracB = oprB[6:0];
//         FracA_ext = (ExpA == 0) ? {1'b0, FracA, 1'b0} : {1'b1, FracA, 1'b0};  // 9 bits
//         FracB_ext = (ExpB == 0) ? {1'b0, FracB, 1'b0} : {1'b1, FracB, 1'b0};  // 9 bits
//         if (ExpA > ExpB) begin
//             ExpDiff = ExpA - ExpB;
//             FracB_ext = FracB_ext >> ExpDiff;
//             ExpR = ExpA;
//         end else begin
//             ExpDiff = ExpB - ExpA;
//             FracA_ext = FracA_ext >> ExpDiff;
//             ExpR = ExpB;
//         end
//         if (SA == SB) begin
//             FracZ = FracA_ext + FracB_ext;
//             SR = SA;
//         end else begin
//             if (FracA_ext >= FracB_ext) begin
//                 FracZ = FracA_ext - FracB_ext;
//                 SR = SA;
//             end else begin
//                 FracZ = FracB_ext - FracA_ext;
//                 SR = SB;
//             end
//         end
//         if (FracZ == 0) begin
//             ExpR = 0;
//             FracR = 0;
//             SR = 0;
//         end else begin
//             shift_amt = 0;
//             casez (FracZ)
//                 10'b1?????????: shift_amt = 4'd0;
//                 10'b01????????: shift_amt = 4'd1;
//                 10'b001???????: shift_amt = 4'd2;
//                 10'b0001??????: shift_amt = 4'd3;
//                 10'b00001?????: shift_amt = 4'd4;
//                 10'b000001????: shift_amt = 4'd5;
//                 10'b0000001???: shift_amt = 4'd6;
//                 10'b00000001??: shift_amt = 4'd7;
//                 10'b000000001?: shift_amt = 4'd8;
//                 10'b0000000001: shift_amt = 4'd9;
//                 default:        shift_amt = 4'd10;
//             endcase
//             FracZ = FracZ << shift_amt;
//             ExpR = ExpR - shift_amt + 1;
//             FracR = FracZ[8:2];
//         end
//         Result = {SR, ExpR, FracR};
//     end
// endmodule