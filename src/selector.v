module mux4 #(parameter WIDTH=32)
(
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input [WIDTH-1:0] in3,
    input [WIDTH-1:0] in4,
    input [1:0] signal,
    output reg [WIDTH-1:0] o
);
always @(*) 
begin
    case (signal)
        2'b00: o<=in1;
        2'b01: o<=in2;
        2'b10: o<=in3;
        2'b11: o<=in4;
    endcase
end


endmodule

module mux2 #(parameter WIDTH=32)(
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input signal,
    output [WIDTH-1:0] o
);
assign o=signal?in2:in1;

endmodule