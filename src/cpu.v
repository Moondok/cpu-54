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
controller controller_inst(.clk(clk),.rst(rst),.decoded_instr(decoded_instr),.decode_ena(decode_ena),.pc_ena(pc_ena),regfile_w(regfile_w));

instrument_decoder decodere_inst(.raw_instruction(instr),.ena(decode_ena),.code(decoded_instr));

ir ir_inst(.clk(clk),.ir_in(ir_in),w_data(instr),.r_data()); // ir stores instr only

pcreg pcreg_inst(.clk(clk),.ena(pc_ena),.rstn(rst),.w_data(npc_value),.r_data);

wire [31:0] Rs_value;
wire [31:0] Rt_value;
regfile regfile_inst(.clk(clk),.rst(rst),.we(regfile_w),.raddr1(instr[25:21]),.raddr2(instr[20:16]),.waddr(),.rdata1(Rs_value),.rdata2(Rt_value),wdata(),.is_overflow(overflow_signal));

endmodule //cpu