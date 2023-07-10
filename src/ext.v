`timescale 1ns / 1ps
module ext #(parameter WIDTH=16)(
    input [WIDTH-1:0] in,
    input sign,
    output [31:0]o
);
assign o=sign?{{(32-WIDTH){in[WIDTH-1]}},in}:{{(32-WIDTH){1'b0}},in};

endmodule