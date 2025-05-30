/*
Alexander Yazdani
University of Southern California
EE533
6 April 2025

BFLOAT16 Multipler Module - b16fpmul tb
16-bit Floating Point Multiplier Testbed

iverilog -o build/tb_b16fpmul.out src/b16fpmul.v tb/tb_b16fpmul.v
vvp build/tb_b16fpmul.out
*/

`timescale 1ns / 1ps

module tb();
    reg [15:0] oprA, oprB;
    wire [15:0] Result;
    integer fileA, fileB, fileOut, fileResult;
    integer i;
    integer dummyA, dummyB;

    b16fpmul fp_mult (.oprA(oprA), .oprB(oprB), .Result(Result));

    function real ieee754_to_real;
        input [15:0] bin;
        reg [7:0] exp;
        reg [6:0] frac;
        reg sign;
        real fraction;
        integer i;
    begin
        sign = bin[15];
        exp = bin[14:7];
        frac = bin[6:0];

        // Normalize fraction (1.xxx)
        fraction = 1.0;
        for (i = 0; i < 10; i = i + 1) begin
            if (frac[i])
                fraction = fraction + (1.0 / (1 << (10 - i)));
        end

        // Apply exponent bias
        ieee754_to_real = fraction * (2.0 ** (exp - 127));

        // Apply sign
        if (sign)
            ieee754_to_real = -ieee754_to_real;
    end
    endfunction


    initial begin
        // Open the input files
        fileA = $fopen("inputs/oprA_mul", "r");
        fileB = $fopen("inputs/oprB_mul", "r");

        // Open the output file
        fileOut = $fopen("outputs/fpmul.out", "w");
        fileResult = $fopen("outputs/result_mul.out", "w");

        i = 1;  // Counter for test case #
        // Continue reading until the end of either file
        while (!$feof(fileA) && !$feof(fileB)) begin

            // Scan the input files for Hex values
            dummyA = $fscanf(fileA, "%h", oprA);
            dummyB = $fscanf(fileB, "%h", oprB);

            // Wait for the output to stabilize
            #10;

            // Format the results and write to output file
            $fdisplay(fileOut, "----- Test Case %0d -----", i);
            $fdisplay(fileOut, "oprA: %b %b %b", oprA[15], oprA[14:7], oprA[6:0]);
            $fdisplay(fileOut, "oprB: %b %b %b", oprB[15], oprB[14:7], oprB[6:0]);
            $fdisplay(fileOut, "Result: %b %b %b", Result[15], Result[14:7], Result[6:0]);
            $fdisplay(fileOut, "FracA = %b", fp_mult.FracA);
            $fdisplay(fileOut, "FracB = %b", fp_mult.FracB);
            $fdisplay(fileOut, "FracZ = %b", fp_mult.FracZ);
            $fdisplay(fileOut, "ExpR = %b", fp_mult.ExpR);

            // $fdisplay(fileOut, "----- Test Case %0d -----", i);
            // $fdisplay(fileOut, "oprA: %f", ieee754_to_real(oprA));
            // $fdisplay(fileOut, "oprB: %f", ieee754_to_real(oprB));
            // $fdisplay(fileOut, "Result: %f", ieee754_to_real(Result));
            $fdisplay(fileResult, "%h", Result);
            // $display("----- Test Case %0d -----", i);
            // $display("oprA: %f", ieee754_to_real(oprA));
            // $display("oprB: %f", ieee754_to_real(oprB));
            // $display("Result: %f", ieee754_to_real(Result));

            i = i + 1;
        end

        // Close the files
        $fclose(fileA);
        $fclose(fileB);
        $fclose(fileOut);

        // Finish the simulation
        $finish;
    end
endmodule
