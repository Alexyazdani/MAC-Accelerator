/*
Alexander Yazdani
University of Southern California
EE533
6 April 2025

BFLOAT16 Adder Module - b16fpmul tb
16-bit Floating Point Adder Testbed

iverilog -o build/tb_b16fpadd_pipe.out src/b16fpadd.v tb/tb_b16fpadd_pipe.v
vvp build/tb_b16fpadd_pipe.out
*/

`timescale 1ns / 1ps

module tb();
    reg clk, rst, valid, pipe_en;
    reg [15:0] oprA, oprB;
    wire [15:0] Result;
    integer fileA, fileB, fileOut, fileResult;
    integer i;
    integer dummyA, dummyB;

    // b16fpadd fp_adder (.oprA(oprA), .oprB(oprB), .Result(Result));
    b16fpadd_pipe fp_adder (.oprA(oprA), .oprB(oprB), .clk(clk), .reset(rst), .pipe_en(pipe_en), .Result(Result));

    function real ieee754_to_real;
        input [15:0] bin;
        reg [4:0] exp;
        reg [9:0] frac;
        reg sign;
        real fraction;
        integer i;
    begin
        sign = bin[15];
        exp = bin[14:10];
        frac = bin[9:0];

        // Normalize fraction (1.xxx)
        fraction = 1.0;
        for (i = 0; i < 10; i = i + 1) begin
            if (frac[i])
                fraction = fraction + (1.0 / (1 << (10 - i)));
        end

        // Apply exponent bias
        ieee754_to_real = fraction * (2.0 ** (exp - 15));

        // Apply sign
        if (sign)
            ieee754_to_real = -ieee754_to_real;
    end
    endfunction
    
    always #5 clk = ~clk;


    initial begin
        clk = 0;
        rst = 1;
        valid = 0;
        oprA = 0;
        oprB = 0;
        pipe_en = 0;
        // Open the input files
        fileA = $fopen("inputs/oprA_add", "r");
        fileB = $fopen("inputs/oprB_add", "r");

        // Open the output file
        fileOut = $fopen("outputs/fpadd.out", "w");
        fileResult = $fopen("outputs/result_add.out", "w");

        i = 1;  // Counter for test case #
        // Continue reading until the end of either file
        #20;
        rst = 0;
        pipe_en = 1;
        #10;
        while (!$feof(fileA) && !$feof(fileB)) begin

            // Scan the input files for Hex values
            dummyA = $fscanf(fileA, "%h", oprA);
            dummyB = $fscanf(fileB, "%h", oprB);

            // Wait for the output to stabilize
            #10;
            // $fdisplay(fileOut, "----- ADD Step %0d -----", i);
            // $display("----- ADD Step %0d -----", i);

            // Format the results and write to output file
            // $fdisplay(fileOut, "----- Test Case %0d -----", i);
            // $fdisplay(fileOut, "oprA: %b %b %b", oprA[15], oprA[14:10], oprA[9:0]);
            // $fdisplay(fileOut, "oprB: %b %b %b", oprB[15], oprB[14:10], oprB[9:0]);
            // $display("oprA: %f", ieee754_to_real(oprA));
            // $display("oprB: %f", ieee754_to_real(oprB));
            // $fdisplay(fileOut, "oprA: %f", ieee754_to_real(oprA));
            // $fdisplay(fileOut, "oprB: %f", ieee754_to_real(oprB));
            // $fdisplay(fileOut, "Result: %b %b %b", Result[15], Result[14:10], Result[9:0]);
            // $fdisplay(fileOut, "FracA = %b", fp_adder.FracA);
            // $fdisplay(fileOut, "FracB = %b", fp_adder.FracB);
            // $fdisplay(fileOut, "FracA_ext = %b", fp_adder.FracA_ext);
            // $fdisplay(fileOut, "FracB_ext = %b", fp_adder.FracB_ext);
            // $fdisplay(fileOut, "FracZ = %b", fp_adder.FracZ);
            // $fdisplay(fileOut, "FracR = %b", fp_adder.FracR);
            // $fdisplay(fileOut, "ExpA = %b", fp_adder.ExpA);
            // $fdisplay(fileOut, "ExpB = %b", fp_adder.ExpB);
            // $fdisplay(fileOut, "ExpDiff = %b", fp_adder.ExpDiff);
            // $fdisplay(fileOut, "ExpR = %b", fp_adder.ExpR);
            // $fdisplay(fileResult, "%h", Result);
            // // $display("----- Test Case %0d -----", i);
            // // $display("oprA: %f", ieee754_to_real(oprA));
            // // $display("oprB: %f", ieee754_to_real(oprB));
            // // $display("Result: %f", ieee754_to_real(Result));

            i = i + 1;
        end
        #10;

        // Close the files
        $fclose(fileA);
        $fclose(fileB);
        $fclose(fileOut);

        // Finish the simulation
        $finish;
    end

    initial begin
        #40;
        while (1) begin
            // $fdisplay(fileOut, "Result: %h", ieee754_to_real(Result));
            // $display("Result: %h", ieee754_to_real(Result));
            $fdisplay(fileResult, "%h", Result);
            #10;
        end
    end
endmodule
