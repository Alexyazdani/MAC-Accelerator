/*
Alexander Yazdani
University of Southern California
EE533
9 April 2025

BFLOAT16 MAC Module - b16fp MAC tb
16-bit Floating Point Multiply-Accumulate Testbed

iverilog -o build/tb_b16fpmac.out src/b16fpmac.v src/b16fpmul.v src/b16fpadd.v tb/tb_b16fpmac.v
vvp build/tb_b16fpmac.out
*/

`timescale 1ns / 1ps

module tb();
    reg clk, rst, valid;
    reg [15:0] oprA, oprB;
    wire [15:0] Result;

    integer fileA, fileB, fileOut, fileResult;
    integer i;
    integer dummyA, dummyB;

    // Instantiate the MAC module
    b16fpmac uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .oprA(oprA),
        .oprB(oprB),
        .Result(Result)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        valid = 0;
        oprA = 0;
        oprB = 0;
        i = 1;

        fileA = $fopen("inputs/oprA_mac", "r");
        fileB = $fopen("inputs/oprB_mac", "r");
        fileOut = $fopen("outputs/fpmac.out", "w");
        fileResult = $fopen("outputs/result_mac.out", "w");

        // Hold reset for 2 cycles
        #20;
        rst = 0;
        #10;
        valid = 1;

        while (!$feof(fileA) && !$feof(fileB)) begin

            // Read next operands
            dummyA = $fscanf(fileA, "%h", oprA);
            dummyB = $fscanf(fileB, "%h", oprB);

            // Write to file
            #10;
            $fdisplay(fileOut, "----- MAC Step %0d -----", i);
            $fdisplay(fileOut, "oprA: %h", oprA);
            $fdisplay(fileOut, "oprB: %h", oprB);

            i = i + 1;

        end
        #10;

        $fclose(fileA);
        $fclose(fileB);
        $fclose(fileOut);
        $fclose(fileResult);

        $finish;
    end

    initial begin
        #60;
        while (1) begin
            $fdisplay(fileOut, "Result: %h", Result);
            $fdisplay(fileResult, "%h", Result);
            #10;
        end
    end
endmodule
