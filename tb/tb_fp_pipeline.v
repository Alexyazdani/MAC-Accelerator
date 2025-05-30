/*
Alexander Yazdani
University of Southern California
EE533
16 April 2025

FP Pipeline Testbed

iverilog -o build/tb_fp_pipeline tb/tb_fp_pipeline.v src/fp_pipeline.v src/b16fpadd_pipe.v src/b16fpmul_pipe.v src/counter.v behav/datamem_behav.v behav/imem_behav.v
vvp build/tb_fp_pipeline
*/

`timescale 1ns/1ps

module tb_fp_pipeline;

    reg clk;
    reg reset;
    reg pipe_en;

    reg [31:0] imem_data;
    reg [11:0] imem_addr;
    reg imem_we;
    reg imem_re;

    reg [15:0] dmem_data_scalar;
    reg [5:0] dmem_addr_scalar;
    reg dmem_we_external_scalar;
    reg dmem_re_external_scalar;

    reg [15:0] dmem_data_batch;
    reg [8:0] dmem_addr_batch;
    reg dmem_we_external_batch;
    reg dmem_re_external_batch;

    reg [15:0] dmem_data_encoded_in;
    reg [8:0] dmem_addr_encoded;
    reg dmem_we_external_encoded;
    reg dmem_re_external_encoded;

    wire [31:0] imem_out;
    wire [15:0] dmem_out_scalar;
    wire [15:0] dmem_out_batch;
    wire [15:0] dmem_out_encoded;

    integer i;
    integer encoded_output;

    fp_pipeline dut (
        .clk(clk),
        .reset(reset),
        .pipe_en(pipe_en),
        .imem_data(imem_data),
        .imem_addr(imem_addr),
        .imem_we(imem_we),
        .imem_re(imem_re),
        .dmem_data_scalar(dmem_data_scalar),
        .dmem_addr_scalar(dmem_addr_scalar),
        .dmem_we_external_scalar(dmem_we_external_scalar),
        .dmem_re_external_scalar(dmem_re_external_scalar),
        .dmem_data_batch(dmem_data_batch),
        .dmem_addr_batch(dmem_addr_batch),
        .dmem_we_external_batch(dmem_we_external_batch),
        .dmem_re_external_batch(dmem_re_external_batch),
        .dmem_data_encoded(dmem_data_encoded_in),
        .dmem_addr_encoded(dmem_addr_encoded),
        .dmem_we_external_encoded(dmem_we_external_encoded),
        .dmem_re_external_encoded(dmem_re_external_encoded),
        .imem_out(imem_out),
        .dmem_out_scalar(dmem_out_scalar),
        .dmem_out_batch(dmem_out_batch),
        .dmem_out_encoded(dmem_out_encoded)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Task to load IMEM, Must be in BINARY
    task load_imem(input reg [255:0] filename);
        integer file, status;
        reg [31:0] instr;
        reg [11:0] addr;
        begin
            file = $fopen(filename, "r");
            if (file == 0) begin
                $display("ERROR: Could not open %s", filename);
                $finish;
            end
            $display("Loading IMEM from %s...", filename);
            @(negedge clk);
            imem_we = 1;
            addr = 0;  // Start at address 0
            while (!$feof(file)) begin
                status = $fscanf(file, "%b\n", instr);
                imem_addr = addr;
                imem_data = instr;
                // $display("Writing IMEM: Addr %0d: %b", addr, instr);
                @(negedge clk);  // Wait for clock edge before next write
                addr = addr + 1;  // Increment address
            end
            imem_we = 0;
            $fclose(file);
        end
    endtask

    // Dump IMEM
    task dump_imem();
        integer i;
        begin
            $display("\nDumping IMEM contents...");
            @(negedge clk);
            imem_re = 1;
            for (i = 0; i < 4096; i = i + 1) begin
                imem_addr = i;
                @(negedge clk);  // Wait for clock edge before reading
                $display("IMEM[%0d] = %b", i, imem_out);
            end
            imem_re = 0;
        end
    endtask

    // Task to load DMEM (SCALAR), Must be in HEX
    task load_dmem_scalar(input reg [255:0] filename);
        integer file, status;
        reg [31:0] data;
        reg [5:0] addr;
        begin
            file = $fopen(filename, "r");
            if (file == 0) begin
                $display("ERROR: Could not open %s", filename);
                $finish;
            end
            $display("Loading DMEM (SCALAR) from %s...", filename);
            @(negedge clk);
            dmem_we_external_scalar = 1;
            addr = 0;  // Start at address 0
            while (!$feof(file)) begin
                status = $fscanf(file, "%h\n", data);
                dmem_addr_scalar = addr;
                dmem_data_scalar = data;
                // $display("Writing DMEM (SCALAR): Addr %0d: %b", addr, data);
                @(negedge clk);  // Wait for clock edge before next write
                addr = addr + 1;  // Increment address
            end
            dmem_we_external_scalar = 0;
            $fclose(file);
        end
    endtask

    // Task to load DMEM (BATCH), Must be in HEX
    task load_dmem_batch(input reg [127:0] filename);
        integer file, status;
        reg [31:0] data;
        reg [8:0] addr;
        begin
            file = $fopen(filename, "r");
            if (file == 0) begin
                $display("ERROR: Could not open %s", filename);
                $finish;
            end
            $display("Loading DMEM (BATCH) from %s...", filename);
            @(negedge clk);
            dmem_we_external_batch = 1;
            addr = 0;  // Start at address 0
            while (!$feof(file)) begin
                status = $fscanf(file, "%h\n", data);
                dmem_addr_batch = addr;
                dmem_data_batch = data;
                // $display("Writing DMEM (BATCH): Addr %0d: %b", addr, data);
                @(negedge clk);  // Wait for clock edge before next write
                addr = addr + 1;  // Increment address
            end
            dmem_we_external_batch = 0;
            $fclose(file);
        end
    endtask

    // Dump Scalar DMEM
    task dump_dmem_scalar;
        begin
            $display("\nDumping DMEM (SCALAR) contents...");
            dmem_we_external_scalar = 0;
            dmem_re_external_scalar = 1;
            for (i = 0; i < 64; i = i + 1) begin
                @(posedge clk);
                dmem_addr_scalar = i[5:0];
                #1;
                $display("Addr %0d: %h", i, dmem_out_scalar);
            end
            dmem_re_external_scalar = 0;
        end
    endtask

    // Dump Batch DMEM
    task dump_dmem_batch;
        begin
            $display("\nDumping DMEM (BATCH) contents...");
            dmem_we_external_batch = 0;
            dmem_re_external_batch = 1;
            for (i = 0; i < 512; i = i + 1) begin
                @(posedge clk);
                dmem_addr_batch = i[5:0];
                #1;
                $display("Addr %0d: %h", i, dmem_out_batch);
            end
            dmem_re_external_batch = 0;
        end
    endtask

    function is_known;
        input [15:0] val;
        integer j;
        begin
            is_known = 1;
            for (j = 0; j < 16; j = j + 1) begin
                if (val[j] === 1'bx || val[j] === 1'bz)
                    is_known = 0;
            end
        end
    endfunction

    // Dump Encoded DMEM
    task dump_dmem_encoded;
        integer i;
        begin
            $display("\nDumping DMEM (ENCODED) contents...");
            @(negedge clk);
            dmem_re_external_encoded = 1;
            for (i = 0; i < 512; i = i + 1) begin
                dmem_addr_encoded = i;
                @(negedge clk);  // Wait for clock edge before reading
                $display("Addr %0d: %h", i, dmem_out_encoded);
            end
            dmem_re_external_encoded = 0;
        end
    endtask

    // Save Encoded DMEM
    task save_dmem_encoded;
        integer i;
        begin
            // encoded_output = $fopen("data_encoded.txt", "w");
            $display("\nSaving DMEM (ENCODED) contents...");
            dmem_re_external_encoded = 1;
            @(negedge clk);  
            for (i = 0; i < 512; i = i + 1) begin
                dmem_addr_encoded = i;
                @(negedge clk);
                if (is_known(dmem_out_encoded)) $fdisplay(encoded_output, "%h", dmem_out_encoded);
                else $fdisplay(encoded_output, "0000");
            end
            dmem_re_external_encoded = 0;
        end
    endtask

    initial begin
        reset = 1;
        pipe_en = 0;
        imem_we = 0;
        imem_re = 0;
        dmem_we_external_scalar = 0;
        dmem_re_external_scalar = 0;
        dmem_we_external_batch = 0;
        dmem_re_external_batch = 0;
        dmem_we_external_encoded = 0;
        dmem_re_external_encoded = 0;
        dmem_data_encoded_in = 16'b0;
        dmem_addr_encoded = 6'b0;

        #20 reset = 0;

        load_imem("imem.txt");
        // load_imem("imem_interleaved.txt");
        // load_imem("imem_test2.txt");

        load_dmem_scalar("dmem_scalar.txt");
        load_dmem_batch("dmem_batch.txt");
        encoded_output = $fopen("dmem_encoded.txt", "w");

        // load_dmem_scalar("dmem_scalar_inverse.txt");
        // load_dmem_batch("data_encoded.txt");
        // encoded_output = $fopen("dmem_decoded.txt", "w");


        pipe_en = 1;

        #42000;

        pipe_en = 0;

        dump_dmem_encoded();
        save_dmem_encoded();
        // DUMPING THE BELOW CAN CAUSE OUTPUT ERRORS
        // dump_dmem_scalar();
        // dump_dmem_batch();
        // dump_imem();
        #10;
        $fclose(encoded_output);
        $finish;
    end

endmodule
