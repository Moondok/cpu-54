`include "alu.v"
`include "z_reg.v"
module cpu (
    input clk,
    input rst,
    input[31:0] instr,
    input[31:0] dmem_data,
    output[31:0] data_addr,
    output [31:0] instr_addr,
    output[31:0] w_data,
    output dmem_w,
    output dmem_r,
    output special_store_signal
);


wire [31:0] operand_a;
wire [31:0] operand_b;
wire [31:0] alu_result;
wire [3:0] alu_control; //controller output

wire zero_signal;
wire carry_signal;
wire negative_signal;
wire overflow_signal;

wire z_value;
wire alu2z;
wire z2npc;

//3 candidates for operand_a : 1.Rs_value 2.ext5 3.Pc
alu alu_inst(.a(operand_a),.b(operand_b),.aluc(alu_control),r(alu_result),.zero(zero_signal)
             .carry(carry_signal),.negative(negative_signal),.overflow(overflow_signal));

z_reg z_reg_inst(.clk(clk),.zin(),.zout(),.rst(rst),.w_data(alu_result),.r_data(z_value));

wire [31:0] npc_value;
npc npc_inst(.rst(rst),);

wire [53:0] decoded_instr;
wire ir_in;
wire decode_ena;
wire pc_ena;
wire regfile_w;
wire ref_waddr_signal;
wire ext5_input_signal;  //decide put which one to ext5
wire ext16_extend_signal1;  //decide how to extend the imm;
controller controller_inst(.clk(clk),.rst(rst),.decoded_instr(decoded_instr),.decode_ena(decode_ena),.pc_ena(pc_ena),regfile_w(regfile_w),.ref_waddr_signal(ref_waddr_signal));

instrument_decoder decodere_inst(.raw_instruction(instr),.ena(decode_ena),.code(decoded_instr));

ir ir_inst(.clk(clk),.ir_in(ir_in),w_data(instr),.r_data()); // ir stores instr only

pcreg pcreg_inst(.clk(clk),.ena(pc_ena),.rstn(rst),.w_data(npc_value),.r_data);

wire [31:0] Rs_value;
wire [31:0] Rt_value;
// for ref's wdata : alternatives contains :1. z value, 2.
// for ref's waddr : alternatives contains :1. instr [15:11](Rd)  2.instr[15:11](Rt) 3.$31(jal)
mux4 #(5) mux4_inst1(.in1(instr[15:11]),.in2(instr[20:16]),.in3(5'd31),.in4(32'bz),.signal(ref_waddr_signal),.o(ref_addr));
regfile regfile_inst(.clk(clk),.rst(rst),.we(regfile_w),.raddr1(instr[25:21]),.raddr2(instr[20:16]),.waddr(ref_addr),.rdata1(Rs_value),.rdata2(Rt_value),wdata(),.is_overflow(overflow_signal));

// choose the input for ext5, 2 alternatives :1. instr[10:6](shamt), for sll srl sra     2.Rs for sllv srlv srav
wire [4:0] ext5_input;
wire [31:0] re_ext5;
mux2 #(5) mux2_inst1(.in1(instr[10:6]),.in2(Rs_value[4:0]),.signal(ext5_input_signal),.o(ext5_input));
ext #(5) ext_inst1(.in(ext5_input),.sign(1'b0),.o(re_ext5));

// to extend 16 bit imm to 32 bit 
wire [31:0] re_ext16;
ext #(16) ext_inst2(.in(instr[15:0]),.sign(ext16_extend_signal1),.o(re_ext16));

wire [31:0] clz_value;
clz clz_inst(.value(Rs_value),.num_zero(clz_value));

endmodule //cpu