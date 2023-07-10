`timescale 1ns / 1ps
module MULT (
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    input start,
    output [63:0] z,
    output done

);


reg aux_reg=0; // on the end of b
reg [31:0] faciend=0;
reg [32:0] factor=0;// why 33 bit: 2 signal bits

reg [1:0]sign=0;//y_n-y_{n-1} //0:0 0 or 1 1   1ï¼?1 0    2ï¼?0 1

//we use booth multiply method
reg [6:0] count=0;
reg [63:0] result=0;
reg [32:0] tmp_result;
reg done_=0;
assign done=done_;
assign z=result;

always @(negedge clk)
begin
    if(reset==1)
    begin
      aux_reg<=0;
      faciend<=0;
      factor<=0;
      sign<=0;
      count<=0;
      done_=1;
      result=0;
      tmp_result<=0;
    end
    else if(start)
    begin
      if(count==0)
      begin
        faciend<=b;
        tmp_result<=0;
        factor<={a[31],a};
        aux_reg<=0;
        count<=count+1;
        done_<=0;
      end

      // in the cycle 1,4,7,10...94 we compute the sign
      else if(count<=95 && count%3==1)  //compute the sign
      begin
        if((aux_reg^faciend[0])==0)
            sign<=0;
        else if(aux_reg==0&&faciend[0]==1)
            sign<=1;
        else
            sign<=2;
        count<=count+1;
      end

      // in the cycle 2,5,8,11,...95, we perform add or minus operation , when index goes 95 ,we get result.
      else if(count<=95&&count%3==2)
      begin
        if(sign==1)
            tmp_result<=tmp_result+~factor+1;
        else if(sign==2)
            tmp_result<=tmp_result+factor;
        count<=count+1;
      end

      // in the cycle 3,6,....93 ,we perform shift operation
      else if(count<=95&&count%3==0)
      begin
        aux_reg<=faciend[0];
        faciend<={tmp_result[0],faciend[31:1]};
        tmp_result<={tmp_result[32],tmp_result[32:1]};
        count<=count+1;
      end
      
      else if(count==96)
      begin
        done_<=1'b1;
        result<={tmp_result[31],tmp_result[31:0],faciend[31:1]};
        count<=0;
      end
    end

    
    
end

endmodule //MULT