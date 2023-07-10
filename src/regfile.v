`timescale 1ns / 1ps
module regfile (
    input clk,
    input rst,
    input we,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    output [31:0] rdata1,
    output [31:0] rdata2,
    input [31:0] wdata,
    input is_overflow // specially for add and sub instruction , if overflow occurs, cancel writing operation
);

wire [31:0] decode_result;
reg [31:0] array_reg[31:0];

assign rdata1=rst?0:array_reg[raddr1];

assign rdata2=rst?0:array_reg[raddr2];


initial
begin
    array_reg[0]<=0;
    array_reg[1]<=0;
    array_reg[2]<=0;
    array_reg[3]<=0;
    array_reg[4]<=0;
    array_reg[5]<=0;
    array_reg[6]<=0;
    array_reg[7]<=0;
    array_reg[8]<=0;
    array_reg[9]<=0;
    array_reg[10]<=0;
    array_reg[11]<=0;
    array_reg[12]<=0;
    array_reg[13]<=0;
    array_reg[14]<=0;
    array_reg[15]<=0;
    array_reg[16]<=0;
    array_reg[17]<=0;
    array_reg[18]<=0;
    array_reg[19]<=0;
    array_reg[20]<=0;
    array_reg[21]<=0;
    array_reg[22]<=0;
    array_reg[23]<=0;
    array_reg[24]<=0;
    array_reg[25]<=0;
    array_reg[26]<=0;
    array_reg[27]<=0;
    array_reg[28]<=0;
    array_reg[29]<=0;
    array_reg[30]<=0;
    array_reg[31]<=0;
end


always @(negedge clk or posedge rst) 
begin
    if(rst)
    begin
      array_reg[0]<=0;
          array_reg[1]<=0;
          array_reg[2]<=0;
          array_reg[3]<=0;
          array_reg[4]<=0;
          array_reg[5]<=0;
          array_reg[6]<=0;
          array_reg[7]<=0;
          array_reg[8]<=0;
          array_reg[9]<=0;
          array_reg[10]<=0;
          array_reg[11]<=0;
          array_reg[12]<=0;
          array_reg[13]<=0;
          array_reg[14]<=0;
          array_reg[15]<=0;
          array_reg[16]<=0;
          array_reg[17]<=0;
          array_reg[18]<=0;
          array_reg[19]<=0;
          array_reg[20]<=0;
          array_reg[21]<=0;
          array_reg[22]<=0;
          array_reg[23]<=0;
          array_reg[24]<=0;
          array_reg[25]<=0;
          array_reg[26]<=0;
          array_reg[27]<=0;
          array_reg[28]<=0;
          array_reg[29]<=0;
          array_reg[30]<=0;
          array_reg[31]<=0;
    end
    else
        begin
        if(we&&!is_overflow&&waddr)
            array_reg[waddr]<=wdata; //reg $zero can not be write in
    end
end


endmodule //regfile