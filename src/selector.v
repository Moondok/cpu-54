`timescale 1ns / 1ps
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

module mux8 #(parameter WIDTH=32)
(
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input [WIDTH-1:0] in3,
    input [WIDTH-1:0] in4,
    input [WIDTH-1:0] in5,
    input [WIDTH-1:0] in6,
    input [WIDTH-1:0] in7,
    input [WIDTH-1:0] in8,
    input [2:0] signal,
    output reg [WIDTH-1:0] o
);
always @(*) 
begin
    case (signal)
        3'b000: o<=in1;
        3'b001: o<=in2;
        3'b010: o<=in3;
        3'b011: o<=in4;
        3'b100: o<=in5;
        3'b101: o<=in6;
        3'b110: o<=in7;
        3'b111: o<=in8;
    endcase
end

endmodule