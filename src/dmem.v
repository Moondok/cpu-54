`timescale 1ns / 1ps
module dmem (
    input clk,
    input dm_w,
    input dm_r,
    input [1:0] store_format_signal,
    input [1:0] detail_pos,
    input [10:0] dm_addr,
    input [31:0] dm_wdata,
    output [31:0] dm_rdata
);


reg [31:0] mem[1023:0];
assign  dm_rdata=dm_r ? mem[dm_addr]:32'bz;
always @(posedge clk) 
begin
    if(dm_w&&store_format_signal==2'b0) //store a word
        mem[dm_addr]<=dm_wdata;
    else if(dm_w&&store_format_signal==2'b01) //store half word
    begin
      if(detail_pos==2'b00)
        mem[dm_addr][15:0]<=dm_wdata[15:0];
      else
        mem[dm_addr][31:16]<=dm_wdata[15:0];
    end
        
    else if(dm_w&&store_format_signal==2'b10) //store a byte
    begin
      if(detail_pos==2'b00)
        mem[dm_addr][7:0]<=dm_wdata[7:0];
      else if(detail_pos==2'b01)
        mem[dm_addr][15:8]<=dm_wdata[7:0];
      else if(detail_pos==2'b10)
        mem[dm_addr][23:16]<=dm_wdata[7:0];
      else if(detail_pos==2'b11)
        mem[dm_addr][31:24]<=dm_wdata[7:0];
    end
        
end


endmodule //dmem