module MULTU (
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    input start,
    output [63:0] z,
    output done
    
);

reg [63:0] stored0=0;
reg [63:0] stored1=0;
reg [63:0] stored2=0;
reg [63:0] stored3=0;
reg [63:0] stored4=0;
reg [63:0] stored5=0;
reg [63:0] stored6=0;
reg [63:0] stored7=0;
reg [63:0] stored8=0;
reg [63:0] stored9=0;
reg [63:0] stored10=0;
reg [63:0] stored11=0;
reg [63:0] stored12=0;
reg [63:0] stored13=0;
reg [63:0] stored14=0;
reg [63:0] stored15=0;
reg [63:0] stored16=0;
reg [63:0] stored17=0;
reg [63:0] stored18=0;
reg [63:0] stored19=0;
reg [63:0] stored20=0;
reg [63:0] stored21=0;
reg [63:0] stored22=0;
reg [63:0] stored23=0;
reg [63:0] stored24=0;
reg [63:0] stored25=0;
reg [63:0] stored26=0;
reg [63:0] stored27=0;
reg [63:0] stored28=0;
reg [63:0] stored29=0;
reg [63:0] stored30=0;
reg [63:0] stored31=0;


// 5- level addition 
reg [63:0] add0_1=0;
reg [63:0] add2_3=0;
reg [63:0] add4_5=0;
reg [63:0] add6_7=0;
reg [63:0] add8_9=0;
reg [63:0] add10_11=0;
reg [63:0] add12_13=0;
reg [63:0] add14_15=0;
reg [63:0] add16_17=0;
reg [63:0] add18_19=0;
reg [63:0] add20_21=0;
reg [63:0] add22_23=0;
reg [63:0] add24_25=0;
reg [63:0] add26_27=0;
reg [63:0] add28_29=0;
reg [63:0] add30_31=0;

//4-level addition
reg [63:0] add0_3=0;
reg [63:0] add4_7=0;
reg [63:0] add8_11=0;
reg [63:0] add12_15=0;
reg [63:0] add16_19=0;
reg [63:0] add20_23=0;
reg [63:0] add24_27=0;
reg [63:0] add28_31=0;

//3-level addition
reg [63:0] add0_7=0;
reg [63:0] add8_15=0;
reg [63:0] add16_23=0;
reg [63:0] add24_31=0;

// 2-level addtion
reg [63:0] add0_15=0;
reg [63:0] add16_31=0;

reg [63:0] res=0;

assign z=res;

reg [2:0] counter=0;
reg done_=1'b1;


always @(negedge clk) 
begin
    if(reset)
    begin
      stored0<=0;
      stored1<=0;
      stored2<=0;
      stored3<=0;
      stored4<=0;
      stored5<=0;
      stored6<=0;
      stored7<=0;
      stored8<=0;
      stored9<=0;
      stored10<=0;
      stored11<=0;
      stored12<=0;
      stored13<=0;
      stored14<=0;
      stored15<=0;
      stored16<=0;
      stored17<=0;
      stored18<=0;
      stored19<=0;
      stored20<=0;
      stored21<=0;
      stored22<=0;
      stored23<=0;
      stored24<=0;
      stored25<=0;
      stored26<=0;
      stored27<=0;
      stored28<=0;
      stored29<=0;
      stored30<=0;
      stored31<=0;

      add0_1<=0;
      add2_3<=0;
      add4_5<=0;
      add6_7<=0;
      add8_9<=0;
      add10_11<=0;
      add12_13<=0;
      add14_15<=0;
      add16_17<=0;
      add18_19<=0;
      add20_21<=0;
      add22_23<=0;
      add24_25<=0;
      add26_27<=0;
      add28_29<=0;
      add30_31<=0;

      add0_3<=0;
      add4_7<=0;
      add8_11<=0;
      add12_15<=0;
      add16_19<=0;
      add20_23<=0;
      add24_27<=0;
      add28_31<=0;

      add0_7<=0;
      add8_15<=0;
      add16_23<=0;
      add24_31<=0;

      add0_15<=0;
      add16_31<=0;
      res<=0;
      counter<=0;
      done_<=1'b1;

    end    
    else if(start)
    begin
      if(counter==3'b000)
        done_<=1'b0;
      counter<=counter+1;
      stored0<=b[0]?{32'b0,a}:64'b0;
      stored1<=b[1]?{31'b0,a,1'b0}:64'b0;
      stored2<=b[2]?{30'b0,a,2'b0}:64'b0;
      stored3<=b[3]?{29'b0,a,3'b0}:64'b0;
      stored4<=b[4]?{28'b0,a,4'b0}:64'b0;
      stored5<=b[5]?{27'b0,a,5'b0}:64'b0;
      stored6<=b[6]?{26'b0,a,6'b0}:64'b0;
      stored7<=b[7]?{25'b0,a,7'b0}:64'b0;
      stored8<=b[8]?{24'b0,a,8'b0}:64'b0;
      stored9<=b[9]?{23'b0,a,9'b0}:64'b0;
      stored10<=b[10]?{22'b0,a,10'b0}:64'b0;
      stored11<=b[11]?{21'b0,a,11'b0}:64'b0;
      stored12<=b[12]?{20'b0,a,12'b0}:64'b0;
      stored13<=b[13]?{19'b0,a,13'b0}:64'b0;
      stored14<=b[14]?{18'b0,a,14'b0}:64'b0;
      stored15<=b[15]?{17'b0,a,15'b0}:64'b0;
      stored16<=b[16]?{16'b0,a,16'b0}:64'b0;
      stored17<=b[17]?{15'b0,a,17'b0}:64'b0;
      stored18<=b[18]?{14'b0,a,18'b0}:64'b0;
      stored19<=b[19]?{13'b0,a,19'b0}:64'b0;
      stored20<=b[20]?{12'b0,a,20'b0}:64'b0;
      stored21<=b[21]?{11'b0,a,21'b0}:64'b0;
      stored22<=b[22]?{10'b0,a,22'b0}:64'b0;
      stored23<=b[23]?{9'b0,a,23'b0}:64'b0;
      stored24<=b[24]?{8'b0,a,24'b0}:64'b0;
      stored25<=b[25]?{7'b0,a,25'b0}:64'b0;
      stored26<=b[26]?{6'b0,a,26'b0}:64'b0;
      stored27<=b[27]?{5'b0,a,27'b0}:64'b0;
      stored28<=b[28]?{4'b0,a,28'b0}:64'b0;
      stored29<=b[29]?{3'b0,a,29'b0}:64'b0;
      stored30<=b[30]?{2'b0,a,30'b0}:64'b0;
      stored31<=b[31]?{1'b0,a,31'b0}:64'b0;

      add0_1<=stored0+stored1;
      add2_3<=stored2+stored3;
      add4_5<=stored4+stored5;
      add6_7<=stored6+stored7;
      add8_9<=stored8+stored9;
      add10_11<=stored10+stored11;
      add12_13<=stored12+stored13;
      add14_15<=stored14+stored15;
      add16_17<=stored16+stored17;
      add18_19<=stored18+stored19;
      add20_21<=stored20+stored21;
      add22_23<=stored22+stored23;
      add24_25<=stored24+stored25;
      add26_27<=stored26+stored27;
      add28_29<=stored28+stored29;
      add30_31<=stored30+stored31;

      add0_3<=add0_1+add2_3;
      add4_7<=add4_5+add6_7;
      add8_11<=add8_9+add10_11;
      add12_15<=add12_13+add14_15;
      add16_19<=add16_17+add18_19;
      add20_23<=add20_21+add22_23;
      add24_27<=add24_25+add26_27;
      add28_31<=add28_29+add30_31;

      add0_7<=add0_3+add4_7;
      add8_15<=add8_11+add12_15;
      add16_23<=add16_19+add20_23;
      add24_31<=add24_27+add28_31;

      add0_15<=add0_7+add8_15;
      add16_31<=add16_23+add24_31;

      res<=add0_15+add16_31;

      if(counter==3'b111)
      begin
        done_<=1'b1;
        counter<=0;
      end

    end
end




endmodule //MULTU