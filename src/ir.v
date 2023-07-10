`timescale 1ns / 1ps
module ir (
    input clk,
    input ir_in,
    input [31:0] w_data,
    output [31:0] r_data
    
);

reg [31:0] data; // note that ir is a register substantialy

// maybe it is not a good idea to set clock edge here, for the write operation should wait for the lower imem read
always @(negedge clk) 
begin
    if(ir_in)
        data<=w_data;    
end


assign r_data=data;

endmodule //ir