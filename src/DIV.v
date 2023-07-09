module DIV (
    input [31:0] dividend,
    input [31:0] divisor,
    input start,
    input clock,
    input reset,
    output [31:0] q,
    output [31:0] r,
    output reg busy
);
wire ready;
reg busy2;
reg r_sign;
reg [4:0] count;
reg [31:0] reg_q;
reg [31:0] reg_b;
reg [31:0] reg_r;
wire [31:0] tmp_r2; // a temporary variable for positive r

assign ready=~busy&busy2;
wire [32:0] sub_add=(r_sign)?({reg_r,reg_q[31]} + {1'b0,reg_b}):({reg_r,reg_q[31]} - {1'b0,reg_b});

assign tmp_r2=r_sign? reg_r+reg_b:reg_r;
assign r=dividend[31]?(~tmp_r2+1):tmp_r2;
assign q=(dividend[31]^divisor[31])?(~reg_q+1):reg_q;

always @(negedge clock or posedge reset) 
begin
    if(reset==1)
    begin
      count<=0;
      busy<=0;
      busy2<=0;
      
    end
    else
    begin
      busy2<=busy;
      if(start)
      begin
        reg_r<=32'b0;
        r_sign<=0;
        reg_q<=dividend[31]? ~dividend+1:dividend;  // tarnsform to  +
        reg_b<=divisor[31]? ~divisor+1:divisor;
        count<=5'b0;
        busy<=1'b1;
      end
      else if(busy)
      begin
        count<=count+1;
        reg_r<=sub_add[31:0];
        r_sign=sub_add[32];
        reg_q<={reg_q[30:0],~sub_add[32]};
        if(count==5'b11111)
            busy<=0;
      end
    end
end

endmodule //DIV