module z_reg (
    input clk,
    input rst,
    input zin,
    input zout,
    input [31:0] w_data,
    input [31:0] r_data
    
);

reg [31:0] data;
always @(negedge clk) 
begin
    if(rst==1'b1)
        data<=32'b0;
    else if(zin==1'b1)
        data<=w_data;
end
assign r_data=zout?data:32'bz;

endmodule //z_reg