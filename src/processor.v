///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: module_template 2008-03-13 gac1 $
//
// Module: ids.v
// Project: NF2.1
// Description: Defines a simple ids module for the user data path.  The
// modules reads a 64-bit register that contains a pattern to match and
// counts how many packets match.  The register contents are 7 bytes of
// pattern and one byte of mask.  The mask bits are set to one for each
// byte of the pattern that should be included in the mask -- zero bits
// mean "don't care".
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module processor 
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
      input                               in_wr,
      output                              in_rdy,

      output [DATA_WIDTH-1:0]             out_data,
      output [CTRL_WIDTH-1:0]             out_ctrl,
      output                              out_wr,
      input                               out_rdy,
      
      // --- Register interface
      input                               reg_req_in,
      input                               reg_ack_in,
      input                               reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

      output                              reg_req_out,
      output                              reg_ack_out,
      output                              reg_rd_wr_L_out,
      output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      // misc
      input                                reset,
      input                                clk
   );

   // Define the log2 function
   // `LOG2_FUNC

   //------------------------- Signals-------------------------------

   // software registers 
   wire [31:0]                   imem_data;
   wire [31:0]                   imem_addr;
   wire [31:0]                   dmem_data_scalar;
   wire [31:0]                   dmem_data_batch;
   wire [31:0]                   dmem_data_encoded;
   wire [31:0]                   dmem_addr_scalar;
   wire [31:0]                   dmem_addr_batch;
   wire [31:0]                   dmem_addr_encoded;
   wire [31:0]                   cmd;
//    wire [31:0]                   ila1_raddr;
//    wire [31:0]                   ila2_raddr;
   
   // hardware registers
   reg [31:0]                    imem_out,dmem_out_scalar,dmem_out_batch,dmem_out_encoded;
   
      // internal siganls
   wire [16:0] dm_out_scalar,dm_out_batch,dm_out_encoded;
   wire [31:0] im_out;
    // reg ila1wea;
    // reg ila2wea;
    // reg [8:0] ila1addr;
    // reg [8:0] ila2addr;
    // wire [31:0] ila1out;
    // wire [31:0] ila2out;
    // reg [31:0] counter;
    // reg [31:0] counter_next;
    // reg [1:0] state;
    // reg [1:0] next_state;


   //------------------------- Modules-------------------------------

	fp_pipeline pipe(
        .clk(clk),
        .reset(reset||cmd[0]),
        .pipe_en(cmd[1]),
        .imem_data(imem_data),
        .imem_addr(imem_addr[11:0]),
        .imem_we(cmd[2]),
        .imem_re(cmd[3]),
        .dmem_data_scalar({dmem_data_scalar[15:0]}),
        .dmem_data_batch({dmem_data_batch[15:0]}),
        .dmem_data_encoded({dmem_data_encoded[15:0]}),
        .dmem_addr_scalar(dmem_addr_scalar[5:0]),
        .dmem_addr_batch(dmem_addr_batch[8:0]),
        .dmem_addr_encoded(dmem_addr_encoded[8:0]),
        .dmem_we_external_scalar(cmd[4]),
        .dmem_we_external_batch(cmd[4]),
        .dmem_we_external_encoded(cmd[4]),
        .dmem_re_external_scalar(cmd[5]),
        .dmem_re_external_batch(cmd[5]),
        .dmem_re_external_encoded(cmd[5]),
        .imem_out(im_out),
        .dmem_out_scalar(dm_out_scalar[15:0]),
        .dmem_out_batch(dm_out_batch[15:0]),
        .dmem_out_encoded(dm_out_encoded[15:0])
        // .ila1addr(ila1addr),
        // .ila2addr(ila2addr),
        // .ila1wea(ila1wea),
        // .ila2wea(ila2wea),
        // .ila1_out(ila1out),
        // .ila2_out(ila2out)
    );


   generic_regs #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`PROC_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`PROC_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (9),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (4)                  // Number of hw regs
   ) module_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface
      .software_regs    ({cmd,imem_data,imem_addr,dmem_data_scalar,dmem_data_batch,dmem_data_encoded,dmem_addr_scalar,dmem_addr_batch,dmem_addr_encoded}),

      // --- HW regs interface
      .hardware_regs    ({imem_out,dmem_out_scalar,dmem_out_batch,dmem_out_encoded}),

      .clk              (clk),
      .reset            (reset)
    );

   //------------------------- Logic-------------------------------
   
   assign out_data  = in_data;
   assign out_ctrl  = in_ctrl;
   assign out_wr    = in_wr;
   assign in_rdy    = out_rdy;  // Passes back the ready signal
   

   
    always @(posedge clk) begin
        if (reset||cmd[0])begin
            imem_out <= 32'd0;
            dmem_out_scalar <= 32'd0;
            dmem_out_batch <= 32'd0;
            dmem_out_encoded <= 32'd0;
        end else begin
            imem_out <= im_out;
            dmem_out_scalar <= {16'b0, dm_out_scalar};
            dmem_out_batch <= {16'b0, dm_out_batch};
            dmem_out_encoded <= {16'b0, dm_out_encoded};
        end
    end



//    always @(*) begin
//     ila1wea = 1'b0;
//     ila2wea = 1'b0;
//     counter_next = counter;
//     next_state = state;
//     ila1addr = counter[8:0];
//     ila2addr = counter[8:0];
//     case (state) 
//         2'b00: begin
//             ila1addr = counter[8:0];
//             ila2addr = counter[8:0]; 
//             if(cmd[1])begin
//                 counter_next = counter + 1;
//                 next_state = 2'b01;
//                 ila1wea = 1'b1;
//                 ila2wea = 1'b1;
//             end else begin
//                 counter_next = counter;
//                 next_state = 2'b00;
//                 ila1wea = 1'b0;
//                 ila2wea = 1'b0;
//             end
//         end
//         2'b01: begin
//             ila1wea = 1'b1;
//             ila2wea = 1'b1;
//             if(counter != 32'd512) begin
//                 counter_next = counter + 1;
//                 next_state = 2'b01;
//                 ila1addr = counter[8:0];
//                 ila2addr = counter[8:0];   
//             end else begin
//                 next_state = 2'b10;
//                 counter_next = counter;
//                 ila1addr = counter[8:0];
//                 ila2addr = counter[8:0]; 
//             end
//         end
//         2'b10: begin 
//             ila1wea = 1'b0;
//             ila2wea = 1'b0;
//             counter_next = counter;
//             next_state = 2'b10;
//             ila1addr = ila1_raddr;
//             ila2addr = ila2_raddr;
//         end
//         2'b11: begin
//             ila1wea = 1'b0;
//             ila2wea = 1'b0;   
//             counter_next = counter;
//             next_state = 2'b00;
//             ila1addr = ila1_raddr;
//             ila2addr = ila2_raddr;
//         end
//     endcase
// end


// always @(posedge clk) begin
//     if (reset||cmd[0]) begin
//         ila1_out<=32'd0;
//         ila2_out<=32'd0;
//     end else begin
//         ila1_out<=ila1out;
//         ila2_out<=ila2out;
//     end
// end
   
   
endmodule 