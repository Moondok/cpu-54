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
    output dmem_r
);


wire [31:0] operand_a;
wire [31:0] operand_b;
wire [31:0] alu_result;
wire [3:0] alu_control; //controller output

wire zero_signal;
wire carry_signal;
wire negative_signal;
wire overflow_signal;

alu alu_inst(.a(operand_a),.b(operand_b),.aluc(alu_control),r(alu_result),.zero(zero_signal)
             .carry(carry_signal),.negative(negative_signal),.overflow(overflow_signal));

z_reg z_reg_inst(.clk(clk),.zin(),.zout(),.rst(rst),.w_data(),.r_data());
endmodule //cpu