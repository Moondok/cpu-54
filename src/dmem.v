module dmem (
    input clk,
    input dm_w,
    input dm_r,
    input [10:0] dm_addr,
    input [31:0] dm_wdata,
    output [31:0] dm_rdata
);


reg [31:0] mem[31:0];
assign  dm_rdata=dm_r ? mem[dm_addr]:32'bz;
always @(posedge clk) 
begin
    if(dm_w)
        mem[dm_addr]<=dm_wdata;
end


endmodule //dmem