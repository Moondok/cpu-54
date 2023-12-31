`timescale 1ns / 1ps
`include "alu.v"
`include "controller.v"
`include "cp0.v"
`include "clz.v"
`include "DIV.v"
`include "DIVU.v"
`include "ext.v"
`include "hilo.v"
`include "instruction_decoder.v"
`include "ir.v"
`include "joint.v"
`include "MDR.v"
`include "MULT.v"
`include "MULTU.v"
`include "npc.v"
`include "pcreg.v"
`include "regfile.v"
`include "selector.v"
`include "z_reg.v"
module cpu (
    input clk,
    input rst,
    input[31:0] instr,
    input[31:0] dmem_data,
    input[1:0] detail_pos,
    output[31:0] data_addr,
    output [31:0] instr_addr,
    output[31:0] w_data,
    output dmem_w,
    output dmem_r,
    output [1:0] store_format_signal
);

wire [31:0] Rs_value;
wire [31:0] Rt_value;
wire Rs_signal;
assign Rs_signal=Rs_value[31]; //decide whether Rs is negative or positive , specially for 'bgez'


wire [31:0] operand_a;
wire [31:0] operand_b;

wire zero_signal;
wire carry_signal;
wire negative_signal;
wire overflow_signal;

wire [31:0] z_value;
wire [31:0] alu_result;

wire [31:0] joint_addr; // for j,jal

wire [31:0] re_ext18;
wire [3:0] alu_control; //controller output

wire [31:0] res_q;
wire [31:0] res_r;

wire [31:0] res_qu;
wire [31:0] res_ru;

wire [63:0] res_mul;
wire [63:0] res_mulu;

//cp0 setting
wire [31:0] cp0_data;
wire [31:0] exc_addr;

// to extend 16 bit imm to 32 bit 
wire [31:0] re_ext_imm;

wire [1:0] npc_input_signal;// choose which data to npc
wire zin;
wire zout;

wire [31:0] npc_value;
wire [31:0] npc_wdata;

wire busy;

wire [31:0] dmem2ref;// for lw lh lhu lb lbu

wire [31:0] re_ext5;

wire npc_in;

wire [31:0] pc_value;


assign instr_addr=pc_value;

assign data_addr=z_value; // the write addr for dmem
assign w_data=Rt_value;
//3 candidates for operand_a : 1.Rs_value 2.ext5 3.Pc 
//4 candidates for operand_b : 1.Rt_value 2.imm 3. 4   4.ext18(bne beq bgez)

// select the operand a
wire [1:0]operand1_signal;
wire [1:0]operand2_signal;
mux4 #(32) mux4_inst4(.in1(Rs_value),.in2(re_ext5),.in3(npc_value),.in4(32'bz),.signal(operand1_signal),.o(operand_a));

//select the operand b
mux4 #(32) mux4_inst5(.in1(Rt_value),.in2(re_ext_imm),.in3(re_ext18),.in4(32'd4),.signal(operand2_signal),.o(operand_b));

alu alu_inst(.a(operand_a),.b(operand_b),.aluc(alu_control),.r(alu_result),.zero(zero_signal),
             .carry(carry_signal),.negative(negative_signal),.overflow(overflow_signal));



z_reg z_reg_inst(.clk(clk),.zin(zin),.zout(zout),.rst(rst),.w_data(alu_result),.r_data(z_value));

// there r 4 potential input for npc : 1.Z value 2.Rs_value(jr) 3.joint_addr 4.exc_addrsys

mux4 #(32) mux4_inst2(.in1(z_value),.in2(Rs_value),.in3(joint_addr),.in4(exc_addr),.signal(npc_input_signal),.o(npc_wdata));

npc npc_inst(.clk(clk),.rst(rst),.data_in(npc_wdata),.npc_in(npc_in),.data_out(npc_value));


//clz setting
wire[31:0] clz_value;

wire [53:0] decoded_instr;
wire ir_in;
wire decode_ena;
wire pc_ena;

wire regfile_w;
wire [1:0]ref_waddr_signal;
wire [2:0]ref_wdata_signal;
wire ext5_input_signal;  //decide put which one to ext5
wire extend16_signal1;  //decide how to extend imem
wire extend16_signal2;
wire extend8_signal1;
wire [1:0] dmem2ref_signal; //choose dmem's data format : half word word or byte to ref
wire MDR_in;
wire hi_ena;
wire lo_ena;
wire cp0_ena;
wire [4:0] cp0_cause;
wire [1:0] hi_input_signal;
wire [1:0] lo_input_signal;
wire div_start;
wire divu_start;
wire mul_start;
wire mulu_start;

controller controller_inst(.clk(clk),.rst(rst),.decoded_instr(decoded_instr),.zero(zero_signal),.Rs_signal(Rs_signal),.busy(busy),.zin(zin),.zout(zout),.pc_ena(pc_ena),.npc_in(npc_in),.decode_ena(decode_ena),.ir_in(ir_in),.regfile_w(regfile_w),
                           .ref_waddr_signal(ref_waddr_signal),.ref_wdata_signal(ref_wdata_signal),.npc_input_signal(npc_input_signal),.ext5_input_signal(ext5_input_signal),.extend16_signal1(extend16_signal1),.extend16_signal2(extend16_signal2),
                           .extend8_signal1(extend8_signal1),.dmem2ref_signal(dmem2ref_signal),.MDR_in(MDR_in),.operand1_signal(operand1_signal),.operand2_signal(operand2_signal),.dmem_w(dmem_w),.dmem_r(dmem_r),.hi_ena(hi_ena),.lo_ena(lo_ena),
                           .hi_input_signal(hi_input_signal),.lo_input_signal(lo_input_signal),.store_format_signal(store_format_signal),.cp0_cause(cp0_cause),.cp0_ena(cp0_ena),.div_start(div_start),.divu_start(divu_start),.mul_start(mul_start),.mulu_start(mulu_start),.alu_control(alu_control));

instrument_decoder decodere_inst(.raw_instruction(instr),.ena(decode_ena),.code(decoded_instr));

wire [31:0] ir_data;
ir ir_inst(.clk(clk),.ir_in(ir_in),.w_data(instr),.r_data(ir_data)); // ir stores instr only


pcreg pc_inst(.clk(clk),.ena(pc_ena),.rstn(rst),.data_in(npc_value),.data_out(pc_value));


wire [31:0] hi_data;
wire [31:0] lo_data;
// for ref's wdata : alternatives contains :1. z value, 2. dmem_data (byte word or half word) dmem2ref 3.clz_value 4.hi_data 5.lo_data 6.cp0_data 7.mul_res[31:0] 
// for ref's waddr : alternatives contains :1. instr [15:11](Rd)  2.instr[15:11](Rt) 3.$31(jal)
wire [4:0] ref_waddr;
wire [31:0] ref_wdata;
mux8 #(32) mux8_inst1(.in1(z_value),.in2(dmem2ref),.in3(clz_value),.in4(hi_data),.in5(lo_data),.in6(cp0_data),.in7(res_mul[31:0]),.in8(32'bz),.signal(ref_wdata_signal),.o(ref_wdata));
mux4 #(5) mux4_inst1(.in1(instr[15:11]),.in2(instr[20:16]),.in3(5'd31),.in4(5'bz),.signal(ref_waddr_signal),.o(ref_waddr));
regfile cpu_ref(.clk(clk),.rst(rst),.we(regfile_w),.raddr1(instr[25:21]),.raddr2(instr[20:16]),.waddr(ref_waddr),.rdata1(Rs_value),.rdata2(Rt_value),.wdata(ref_wdata),.is_overflow(overflow_signal));

// choose the input for ext5, 2 alternatives :1. instr[10:6](shamt), for sll srl sra     2.Rs for sllv srlv srav
wire [4:0] ext5_input;

mux2 #(5) mux2_inst1(.in1(instr[10:6]),.in2(Rs_value[4:0]),.signal(ext5_input_signal),.o(ext5_input));
ext #(5) ext_inst1(.in(ext5_input),.sign(1'b0),.o(re_ext5));


ext #(16) ext_inst2(.in(instr[15:0]),.sign(extend16_signal1),.o(re_ext_imm));

clz clz_inst(.value(Rs_value),.num_zero(clz_value));

wire [31:0] MDR_data;
MDR MDR_inst(.clk(clk),.rst(rst),.data_in(dmem_data),.ena(MDR_in),.data_out(MDR_data));

wire [31:0] re_ext_dmem_b;
wire [31:0] re_ext_dmem_hw;
wire [7:0] load_byte_extend_input;
wire [15:0] load_hw_exntend_input;
assign load_byte_extend_input=(detail_pos==2'b00)?MDR_data[7:0]:((detail_pos==2'b01)?MDR_data[15:8]:((detail_pos==2'b10)?MDR_data[23:16]:MDR_data[31:24]));
assign load_hw_exntend_input=(detail_pos==2'b00)?MDR_data[15:0]:MDR_data[31:16];
ext #(8) ext_inst3(.in(load_byte_extend_input),.sign(extend8_signal1),.o(re_ext_dmem_b)); //b means byte
ext #(16) ext_inst4(.in(load_hw_exntend_input),.sign(extend16_signal2),.o(re_ext_dmem_hw)); // hw means half word


mux4 #(32) mux4_inst3(.in1(MDR_data),.in2(re_ext_dmem_hw),.in3(re_ext_dmem_b),.in4(32'bz),.signal(dmem2ref_signal),.o(dmem2ref));

//store
// here we do not execute any extend opretation ,we control the wirte byte ,write half word directly in the dmem module by control signal


//bne beq,bgez due to the extend method always be signed  we set sign as 1'b1

ext #(18) ext_inst5(.in({instr[15:0],2'b00}),.sign(1'b1),.o(re_ext18));



// the input for joint is pc or npc is still unknown
joint joint_inst(.pc_value(npc_value[31:28]),.jump_value({instr[25:0],2'b00}),.joint_addr(joint_addr));
  
// there r ( ) candidates for hi_data : 1.Rs_value   2.r in div  3. ru in divu 4.res_mulu[63:32]

wire [31:0] hi_input;
mux4 #(32) mux4_inst6(.in1(Rs_value),.in2(res_r),.in3(res_ru),.in4(res_mulu[63:32]),.signal(hi_input_signal),.o(hi_input));
hilo hi_reg(.clk(clk),.rst(rst),.wdata(hi_input),.wena(hi_ena),.rdata(hi_data));
// there r ( ) candidates for lo_data : 1.Rs_value  2. q in div  3. qu in divu  4. res_mul[31:0]
wire [31:0] lo_input;
mux4 #(32) mux4_inst7(.in1(Rs_value),.in2(res_q),.in3(res_qu),.in4(res_mulu[31:0]),.signal(lo_input_signal),.o(lo_input));
hilo lo_reg(.clk(clk),.rst(rst),.wdata(lo_input),.wena(lo_ena),.rdata(lo_data));

CP0 cp0_inst(.clk(clk),.rst(rst),.ena(cp0_ena),.mfc0(decoded_instr[44]),.mtc0(decoded_instr[45]),.npc(npc_value),.Rd(instr[15:11]),.wdata(Rt_value),
             .exception(decoded_instr[51]||decoded_instr[52]||decoded_instr[53]),.eret(decoded_instr[50]),.cause(cp0_cause),.rdata(cp0_data),.exc_addr(exc_addr));




wire mul_done;
wire mulu_done;
wire div_busy;
wire divu_busy;
assign busy=(~mul_done)|(~mulu_done)|div_busy|divu_busy;


DIV div_inst(.dividend(Rs_value),.divisor(Rt_value),.start(div_start),.clock(clk),.reset(rst),.q(res_q),.r(res_r),.busy(div_busy));

DIVU divu_inst(.dividend(Rs_value),.divisor(Rt_value),.start(divu_start),.clock(clk),.reset(rst),.q(res_qu),.r(res_ru),.busy(divu_busy));


MULT mult_inst(.clk(clk),.reset(rst),.a(Rs_value),.b(Rt_value),.start(mul_start),.z(res_mul),.done(mul_done));
MULTU multu_inst(.clk(clk),.reset(rst),.a(Rs_value),.b(Rt_value),.start(mulu_start),.z(res_mulu),.done(mulu_done));

endmodule //cpu