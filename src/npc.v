`timescale 1ns / 1ps
module npc (
    input clk,
    input [31:0] data_in,
    input npc_in, //signal for write
    input rst,
    output [31:0] data_out
);

reg [31:0] next_instr_addr;
always @(negedge clk) 
begin
    if(rst)
        next_instr_addr<=32'h00400000;
    else if(npc_in)
        next_instr_addr<=data_in;
    
end

assign data_out=next_instr_addr;


endmodule //npc