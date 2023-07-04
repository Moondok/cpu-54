module clz (
    input [31:0] value,
    output reg [31:0] num_zero
);
always@(*)
    begin
    if(value[31]) 
        num_zero<=32'd0;
    else if(value[30]) 
        num_zero<=32'd1;
    else if(value[29]) 
        num_zero<=32'd2;
    else if(value[28]) 
        num_zero<=32'd3;
    else if(value[27]) 
        num_zero<=32'd4;
    else if(value[26])     
        num_zero<=32'd5;
    else if(value[25]) 
        num_zero<=32'd6;
    else if(value[24]) 
        num_zero<=32'd7;
    else if(value[23]) 
        num_zero<=32'd8;
    else if(value[22]) 
        num_zero<=32'd9;
    else if(value[21]) 
        num_zero<=32'd10;
    else if(value[20]) 
        num_zero<=32'd11;
    else if(value[19]) 
        num_zero<=32'd12;
    else if(value[18]) 
        num_zero<=32'd13;
    else if(value[17]) 
        num_zero<=32'd14;
    else if(value[16]) 
        num_zero<=32'd15;
    else if(value[15]) 
        num_zero<=32'd16;
    else if(value[14]) 
        num_zero<=32'd17;
    else if(value[13]) 
        num_zero<=32'd18;
    else if(value[12]) 
        num_zero<=32'd19;
    else if(value[11]) 
        num_zero<=32'd20;
    else if(value[10]) 
        num_zero<=32'd21;
    else if(value[9]) 
        num_zero<=32'd22;
    else if(value[8]) 
        num_zero<=32'd23;
    else if(value[7]) 
        num_zero<=32'd24;
    else if(value[6]) 
        num_zero<=32'd25;
    else if(value[5]) 
        num_zero<=32'd26;
    else if(value[4]) 
        num_zero<=32'd27;
    else if(value[3]) 
        num_zero<=32'd28;
    else if(value[2]) 
        num_zero<=32'd29;
    else if(value[1]) 
        num_zero<=32'd30;
    else if(value[0]) 
        num_zero<=32'd31;
    else 
        num_zero<=32'd32;
    end

endmodule //clz