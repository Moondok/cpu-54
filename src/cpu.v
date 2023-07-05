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
    output [1:0] store_format_signal
);

wire Rs_signal=Rs_value[31]; //decide whether Rs is negative or positive , specially for 'bgez'


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

assign data_addr=z_value; // the write addr for dmem
assign w_data=Rt_value;
//3 candidates for operand_a : 1.Rs_value 2.ext5 3.Pc 
//4 candidates for operand_b : 1.Rt_value 2.imm 3. 4   4.ext18(bne beq bgez)

// select the operand a
mux4 #(32) mux4_inst4(.in1(Rs_value),.in2(re_ext5),.in3(npc_value),.in4(32'bz),.signal(operand1_signal),.o(operand_a));

//select the operand b
mux4 #(32) mux4_inst5(.in1(Rt_value),.in2(re_ext_imm),.in3(re_ext18),.in4(32'd4),.signal(operand2_signal),.o(operand_b));

alu alu_inst(.a(operand_a),.b(operand_b),.aluc(alu_control),r(alu_result),.zero(zero_signal)
             .carry(carry_signal),.negative(negative_signal),.overflow(overflow_signal));



z_reg z_reg_inst(.clk(clk),.zin(zin),.zout(zout),.rst(rst),.w_data(alu_result),.r_data(z_value));

// there r 4 potential input for npc : 1.Z value 2.Rs_value(jr)
wire [31:0] npc_value;
mux4 #(32) mux4_inst2(.in1(z_value),.in2(Rs_value),.in3(),.in4(),.signal(),o(npc_wdata));
wire [31:0] npc_wdata;
npc npc_inst(.rst(rst),.data_in(npc_wdata),.npc_in(npc_in),.data_out(npc_value));

wire [53:0] decoded_instr;
wire ir_in;
wire decode_ena;
wire pc_ena;
wire [31:0] npc_in;
wire regfile_w;
wire [1:0]ref_waddr_signal;
wire ext5_input_signal;  //decide put which one to ext5
wire extend16_signal1;  //decide how to extend imem
wire extend16_signal2;
wire extend8_signal1;
wire [1:0] dmem2ref_signal; //choose dmem's data format : half word word or byte to ref
wire npc_input_signal;// choose which data to npc
wire zin;
wire zout;
wire MDR_in;
wire [1:0]operand1_signal;
wire [1:0]operand2_signal;
controller controller_inst(.clk(clk),.rst(rst),.decoded_instr(decoded_instr),.decode_ena(decode_ena),.pc_ena(pc_ena),regfile_w(regfile_w),
                           .ref_waddr_signal(ref_waddr_signal),.zero(zero_signal),.Rs_signal(Rs_signal));

instrument_decoder decodere_inst(.raw_instruction(instr),.ena(decode_ena),.code(decoded_instr));

ir ir_inst(.clk(clk),.ir_in(ir_in),w_data(instr),.r_data()); // ir stores instr only

wire [31:0] pc_value;
pcreg pc_inst(.clk(clk),.ena(pc_ena),.rstn(rst),.w_data(npc_value),.r_data(pc_value));

wire [31:0] Rs_value;
wire [31:0] Rt_value;
// for ref's wdata : alternatives contains :1. z value, 2. dmem_data (byte word or half word) dmem2ref
// for ref's waddr : alternatives contains :1. instr [15:11](Rd)  2.instr[15:11](Rt) 3.$31(jal)
mux4 #(5) mux4_inst1(.in1(instr[15:11]),.in2(instr[20:16]),.in3(5'd31),.in4(32'bz),.signal(ref_waddr_signal),.o(ref_addr));
regfile cpu_ref(.clk(clk),.rst(rst),.we(regfile_w),.raddr1(instr[25:21]),.raddr2(instr[20:16]),.waddr(ref_addr),.rdata1(Rs_value),.rdata2(Rt_value),wdata(),.is_overflow(overflow_signal));

// choose the input for ext5, 2 alternatives :1. instr[10:6](shamt), for sll srl sra     2.Rs for sllv srlv srav
wire [4:0] ext5_input;
wire [31:0] re_ext5;
mux2 #(5) mux2_inst1(.in1(instr[10:6]),.in2(Rs_value[4:0]),.signal(ext5_input_signal),.o(ext5_input));
ext #(5) ext_inst1(.in(ext5_input),.sign(1'b0),.o(re_ext5));

// to extend 16 bit imm to 32 bit 
wire [31:0] re_ext_imm;
ext #(16) ext_inst2(.in(instr[15:0]),.sign(ext16_extend_signal1),.o(re_ext_imm));

wire [31:0] clz_value;
clz clz_inst(.value(Rs_value),.num_zero(clz_value));

wire [31:0] MDR_data;
MDR MDR_inst(.clk(clk),.rst(rst),.data_in(dmem_data),.ena(MDR_in),.data_out(MDR_data));

ext #(8) ext_inst3(.in(dmem_data[7:0]),.sign(extend_signal),.o(re_ext_dmem_b)); //b means byte
ext #(16) ext_inst4(.in(dmem_data[15:0]),.sign(extend_signal),.o(re_ext_dmem_hw)); // hw means half word

wire [31:0] dmem2ref;// for lw lh lhu lb lbu
mux4 #(32) mux4_inst3(.in1(dmem_data),.in2(re_ext_dmem_hw),.in3(re_ext_dmem_b),.in4(32'bz),.signal(dmem2ref_signal),.o(dmem2ref));

//store
// here we do not execute any extend opretation ,we control the wirte byte ,write half word directly in the dmem module by control signal


//bne beq,bgez due to the extend method always be signed  we set sign as 1'b1
wire [31:0] re_ext18;
ext #(18) ext_inst5(.in({instr[15:0],2'b00}),.sign(1'b1),.o(re_ext18));
endmodule //cpu