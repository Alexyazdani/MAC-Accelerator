/*
Alexander Yazdani
University of Southern California
EE533
14 April 2025

FP Pipeline
*/

module fp_pipeline (
    input wire clk,
    input wire reset,
    input wire pipe_en,

    input wire [31:0] imem_data,
    input wire [11:0] imem_addr,
    input wire imem_we,
    input wire imem_re,

    input wire [15:0] dmem_data_scalar,
    input wire [5:0] dmem_addr_scalar,
    input wire dmem_we_external_scalar,
    input wire dmem_re_external_scalar,

    input wire [15:0] dmem_data_batch,
    input wire [8:0] dmem_addr_batch,
    input wire dmem_we_external_batch,
    input wire dmem_re_external_batch,

    input wire [15:0] dmem_data_encoded,
    input wire [8:0] dmem_addr_encoded,
    input wire dmem_we_external_encoded,
    input wire dmem_re_external_encoded,

    output [31:0] imem_out,
    output [15:0] dmem_out_scalar,
    output [15:0] dmem_out_batch,
    output [15:0] dmem_out_encoded

    // input wire [8:0] ila1addr,
	// input wire ila1wea,
	// output [31:0] ila1_out,

    // input wire [8:0] ila2addr,
	// input wire ila2wea,
	// output [31:0] ila2_out

	// input wire fifo_re_external,
	// input wire fifo_we_external,
	// input wire firstword,
	// input wire lastword,
	// input wire [71:0] fifo_packet,
	// output [71:0] out_fifo,
	// output valid_data,

    // input wire data_ready,
    // output proc_done
);

// Stage Registers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

reg [31:0] IF_ID_reg;
reg [42:0] ID_MUL_reg;
reg [26:0] MUL_ACC_reg;
reg [26:0] ACC_MEM_reg;

// IF Stage ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

wire [11:0] PC;
reg [11:0] PC_IF;

wire mem_en;
reg proc_en;

assign mem_en = pipe_en;
always @(posedge clk) begin
    if (reset) begin
        proc_en <= 1'b0;
    end else begin
        proc_en <= mem_en;
    end
end


counter12b PC_counter (
    .clk(clk),
    .reset(reset),
    .pipe_en(mem_en),
    .in(PC),
    .load(),
    .load_en(1'b0),
    .out(PC)
);

imem_4096 instr_mem (
    .addr((imem_re||imem_we) ? imem_addr : PC),
    .din(imem_data),
    .clk(clk),
    .we(imem_we),
    .dout(imem_out)
);

always @(posedge clk) begin
    if (reset) begin
        IF_ID_reg[31:0] <= 32'b0;   //Replace with NOOP
        PC_IF <= 12'b0;
    end else if (proc_en) begin
        IF_ID_reg <= imem_out;
        PC_IF <= PC;
    end 
end

// ID Stage ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

wire [5:0] raddr_scalar;
wire [8:0] raddr_batch;
wire [8:0] waddr;
wire wEn;
wire valid;

assign raddr_batch = IF_ID_reg[8:0];
assign raddr_scalar = IF_ID_reg[14:9];
assign waddr = IF_ID_reg[23:15];
assign wEn = IF_ID_reg[29];
assign valid = IF_ID_reg[28];

wire [15:0] fp0data_ID;
wire [15:0] fp1data_ID;

datamem dmem_scalar (
    .clk(clk),
    .waddr(dmem_addr_scalar),
    .raddr(dmem_re_external_scalar ? dmem_addr_scalar : raddr_scalar),
    .din(dmem_data_scalar),
    .wea(dmem_we_external_scalar),
    .dout(fp0data_ID)
);
assign dmem_out_scalar = fp0data_ID;

datamem_512 dmem_batch (
    .clk(clk),
    .waddr(dmem_addr_batch),
    .raddr(dmem_re_external_batch ? dmem_addr_batch : raddr_batch),
    .din(dmem_data_batch),
    .wea(dmem_we_external_batch),
    .dout(fp1data_ID)
);
assign dmem_out_batch = fp1data_ID;

reg [8:0] waddr_ID;
reg wEn_ID;
reg valid_ID;

always @(posedge clk) begin
    if (reset) begin
        wEn_ID <= 1'b0;
        ID_MUL_reg[41] <= 1'b0;
        ID_MUL_reg[42] <= 1'b0;
        valid_ID <= 1'b0;
    end else if (proc_en) begin
        ID_MUL_reg[15:0] <= fp0data_ID;
        ID_MUL_reg[31:16] <= fp1data_ID;
        ID_MUL_reg[40:32] <= waddr_ID;
        ID_MUL_reg[41] <= wEn_ID;
        ID_MUL_reg[42] <= valid_ID;
        valid_ID <= valid;
        waddr_ID <= waddr;
        wEn_ID <= wEn;
    end
end

// FP MUL Stage ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

wire [15:0] fp0data_MUL;
wire [15:0] fp1data_MUL;
wire [15:0] fpmul;
wire [8:0] waddr_MUL;
wire wEn_MUL;
wire valid_MUL;

assign fp0data_MUL = ID_MUL_reg[15:0];
assign fp1data_MUL = ID_MUL_reg[31:16];
assign waddr_MUL = ID_MUL_reg[40:32];
assign wEn_MUL = ID_MUL_reg[41];
assign valid_MUL = ID_MUL_reg[42];

// b16fpmul_ fpmult_pipe (
//     .oprA(fp0data_MUL),
//     .oprB(fp1data_MUL),
//     .Result(fpmul)
// );

// always @(posedge clk) begin
//     if (reset) begin
//         MUL_ACC_reg <= 23'b0;
//     end else if (proc_en) begin
//         MUL_ACC_reg[15:0] <= fpmul;
//         MUL_ACC_reg[21:16] <= waddr_MUL;
//         MUL_ACC_reg[22] <= wEn_MUL;
//     end
// end

b16fpmul_pipe fpmult_pipe (
    .clk(clk),
    .rst(reset),
    .oprA(fp0data_MUL),
    .oprB(fp1data_MUL),
    .Result(fpmul)
);

reg [8:0] waddr_MUL_reg;        // Since we have pipelined the multiplier, we need to delay the write address/enable
reg wEn_MUL_reg;
reg valid_MUL_reg;
always @(posedge clk) begin
    if (reset) begin
        waddr_MUL_reg <= 9'b0;
        wEn_MUL_reg <= 1'b0;
        valid_MUL_reg <= 1'b0;
    end else if (proc_en) begin
        waddr_MUL_reg <= waddr_MUL;
        wEn_MUL_reg <= wEn_MUL;
        valid_MUL_reg <= valid_MUL;
    end
end

always @(posedge clk) begin
    if (reset) begin
        MUL_ACC_reg <= 27'b0;
    end else if (proc_en) begin
        MUL_ACC_reg[15:0] <= fpmul;
        MUL_ACC_reg[24:16] <= waddr_MUL_reg;
        MUL_ACC_reg[25] <= wEn_MUL_reg;
        MUL_ACC_reg[26] <= valid_MUL_reg;
    end
end

// FP ACC Stage ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

wire [15:0] fp2data_ACC;
wire [15:0] fp3data_ACC;
wire [15:0] fpaccum;
wire [8:0] waddr_ACC;
wire wEn_ACC;
wire valid_ACC;

assign valid_ACC = MUL_ACC_reg[26];
assign fp2data_ACC = valid_ACC ? MUL_ACC_reg[15:0] : 16'b0;
assign waddr_ACC = MUL_ACC_reg[24:16];
assign wEn_ACC = MUL_ACC_reg[25];


// b16fpadd fpacc(
//     .oprA(fp2data_ACC),
//     .oprB(fp3data_ACC),
//     .Result(fpaccum)
// );

// always @(posedge clk) begin
//     if (reset) begin
//         ACC_MEM_reg[22] <= 1'b0;
//     end else if (proc_en) begin
//         ACC_MEM_reg[15:0] <= fpaccum;
//         ACC_MEM_reg[21:16] <= waddr_ACC;
//         ACC_MEM_reg[22] <= wEn_ACC;
//     end
// end

b16fpadd_pipe fpacc(
    .oprA(fp2data_ACC),
    .oprB(fp3data_ACC),
    .clk(clk),
    .reset(reset),
    .pipe_en(proc_en),
    .Result(fpaccum)
);

reg [8:0] waddr_ACC_reg;        // Since we have pipelined the accumulator, we need to delay the write address/enable
reg wEn_ACC_reg;
reg valid_ACC_reg;
always @(posedge clk) begin
    if (reset) begin
        waddr_ACC_reg <= 9'b0;
        wEn_ACC_reg <= 1'b0;
        valid_ACC_reg <= 1'b0;
    end else if (proc_en) begin
        waddr_ACC_reg <= waddr_ACC;
        wEn_ACC_reg <= wEn_ACC;
        valid_ACC_reg <= valid_ACC;
    end
end

always @(posedge clk) begin
    if (reset) begin
        ACC_MEM_reg[25] <= 1'b0;
    end else if (proc_en) begin
        ACC_MEM_reg[15:0] <= fpaccum;
        ACC_MEM_reg[24:16] <= waddr_ACC_reg;
        ACC_MEM_reg[25] <= wEn_ACC_reg;
        ACC_MEM_reg[26] <= valid_ACC_reg;
    end
end


// MEM Stage ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

wire [15:0] fpmulacc;
wire [8:0] waddr_MEM;
wire wEn_MEM;
wire valid_MEM;

assign fpmulacc = ACC_MEM_reg[15:0];
assign valid_MEM = ACC_MEM_reg[26];
assign fp3data_ACC = (wEn_MEM||!valid_MEM) ? 16'b0 : fpmulacc;
assign waddr_MEM = ACC_MEM_reg[24:16];
assign wEn_MEM = ACC_MEM_reg[25];

datamem_512 dmem_encoded (
    .clk(clk),
    .waddr(dmem_we_external_encoded ? dmem_addr_encoded : waddr_MEM),
    .raddr(dmem_addr_encoded),
    .din(dmem_we_external_encoded ? dmem_data_encoded : fpmulacc),
    .wea(dmem_we_external_encoded || wEn_MEM),
    .dout(dmem_out_encoded)
);


// Debug ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// imem ILA (
//     .addr (ila1addr[8:0]),
//     .clk  (clk),
//     .din  ({fpaccum,fp2data_ACC}),
//     .dout (ila1_out),
//     .we   (ila1wea)
// );

// imem ILA2 (
//     .addr (ila2addr[8:0]),
//     .clk  (clk),
//     .din  ({fp3data_ACC,valid_MEM,wEn_MEM,waddr_MEM,5'b0}),
//     .dout (ila2_out),
//     .we   (ila2wea)
// );


endmodule