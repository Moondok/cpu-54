`timescale 1ns / 1ps
module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] aluc,
    output [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow
);

localparam ADD=4'b0000; //also for addi
localparam ADDU=4'b0001; //also for addiu
localparam SUB=4'b0010;
localparam SUBU=4'b0011;
localparam AND=4'b0100; //also for andi
localparam OR=4'b0101; //also for ori
localparam XOR=4'b0110; //also for xori
localparam NOR=4'b0111;
localparam SLT=4'b1000; //also for slti
localparam SLTU=4'b1001; //also for sltiu
localparam SLL=4'b1010; // also for sllv
localparam SRL=4'b1011; // also for srlv
localparam SRA=4'b1100; //also for srav
localparam LUI=4'b1101;

reg [32:0] tmp;

always @(*)
    begin
        case(aluc)
        ADD:
          tmp<=a+b;
        
        ADDU:
          tmp<=a+b;
        
        SUB:
          tmp<=a-b;

        SUBU:
          tmp<=a-b;

        AND:
          tmp<=a&b;
        
        OR:
          tmp<=a|b;
        
        XOR:
          tmp<=a^b;

        NOR:
          tmp<=~(a|b);

        SLT:
          tmp<=$signed(a)<$signed(b)?1:0;

        SLTU:
          tmp<=a<b?1:0;

        SLL:
          tmp<=b<<a;

        SRL:
          tmp<=b>>a;
        
        SRA:
          tmp<=$signed(b)>>>a;

        LUI:
          tmp<={b[15:0],16'b0};
        
          
       default:
          tmp=0;
       endcase
    
    end
assign carry=0;
assign negative=tmp[31];
assign zero=(tmp==0);
assign r=tmp[31:0];
assign overflow=((aluc==ADD)&&(a[31]==b[31])&&(a[31]!=tmp[31]))||((aluc==SUB)&&((a[31]&&!b[31]&&!tmp[31])||(!a[31]&&b[31]&&tmp[31])));
endmodule //alu