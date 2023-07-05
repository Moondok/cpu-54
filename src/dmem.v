module dmem (
    input clk,
    input dm_w,
    input dm_r,
    input special_store_signal,
    input [10:0] dm_addr,
    input [31:0] dm_wdata,
    output [31:0] dm_rdata
);


reg [31:0] mem[1023:0];
assign  dm_rdata=dm_r ? mem[dm_addr]:32'bz;
always @(posedge clk) 
begin
    if(dm_w&&special_store_signal==2'b0) //store a word
        mem[dm_addr]<=dm_wdata;
    else if(dm_w&&special_store_signal==2'b01) //store half word
        mem[dm_addr][15:0]<=dm_wdata[15:0];
    else if(dm_w&&special_store_signal==2'b10) //store a byte
        mem[dm_addr][7:0]<=dm_wdata[7:0];
end


endmodule //dmem