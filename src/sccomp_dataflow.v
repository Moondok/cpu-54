`include "dmem.v"
`include "imem.v"
`include "cpu.v"
`timescale 1ns / 1ps
module sccomp_dataflow (
    input clk_in, //posedge write regfile or dmem, negedge write pc
    input reset, //1: reset   0: doing nothing
    // // 
    // output [7:0] o_seg,
    // output [7:0] o_sel
    
   output [31:0]pc,
   output [31:0]inst
    
);


wire [31:0] instr_addr_read;
    
wire [31:0] instruction;

wire [31:0] w_data;
wire [31:0] r_data;

// get the data addr and instr addr from cpu module ,the perform mapping operation to them
wire [31:0] data_addr_read;


// input to imem and dmem
wire [10:0] data_addr; //for read and write can't be executed simultaneously ,so share a public addr
wire [10:0] instruction_addr;

// mapping operation
assign data_addr=(data_addr_read-32'h10010000)/4;
assign instruction_addr=(instr_addr_read-32'h00400000)/4;


wire dmem_w;
wire dmem_r;
wire [1:0] store_format_signal;
wire [1:0] detail_pos; // for sh sb lh lhu lb lbu
assign detail_pos=data_addr_read[1:0];

cpu sccpu(.clk(clk_in),.rst(reset),.instr(instruction),.dmem_data(r_data),.data_addr(data_addr_read),.w_data(w_data),
    .instr_addr(instr_addr_read),.dmem_r(dmem_r),.dmem_w(dmem_w),.store_format_signal(store_format_signal),.detail_pos(detail_pos));

dmem dmem_inst(.clk(clk_in),.dm_w(dmem_w),.dm_r(dmem_r),.dm_addr(data_addr),.dm_wdata(w_data),.dm_rdata(r_data),.store_format_signal(store_format_signal),.detail_pos(detail_pos));

imem imem_inst(.a(instruction_addr),.spo(instruction));

assign pc=instr_addr_read;
assign inst=instruction;

//for board
// divider divider_inst(.I_CLK(clk_in),.rst(1'b0),.O_CLK(clk_in_));

// seg7x16 seg7x16_inst(.clk(clk_in),.reset(reset),.cs(1'b1),.i_data(instr_addr_read),.o_seg(o_seg),.o_sel(o_sel));




endmodule //sccomp_dataflow