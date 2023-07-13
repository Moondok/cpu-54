`timescale 1ns / 1ps

module divider(
    input I_CLK,
    input rst,
    output reg O_CLK
    );
    
    parameter cycle=1000000; // the frequency in board is 100m hz, our cpu's psriod is 100ns, so we need integrate 10 periods into one period, thus cycle=10
    
    reg [31:0] cnt=32'b00000000;
    initial begin
    O_CLK=0;
    end
    always @ (posedge I_CLK)
    begin
    if(rst==1)
    begin
    O_CLK=0;
    cnt=32'b00000000;
    end
    
    else
    
    
    begin
    cnt=(cnt+1)%cycle;
    if(cnt%(cycle/2)==0)
    begin
    O_CLK=~O_CLK;
    end
    end
    
    end

endmodule
