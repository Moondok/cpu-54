`timescale 1ns / 1ps
module MDR (
    input clk,
    input rst,
    input [31:0] data_in,
    input ena,
    output [31:0] data_out
);
reg [31:0]data;
always @(negedge clk) 
begin
    if(rst)
        data<=32'b0;
    else if(ena)
        data<=data_in;

    
end
assign data_out=data;

endmodule //MDR