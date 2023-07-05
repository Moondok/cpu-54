module ext #(parameter WIDTH=16)(
    input [WIDTH-1:0] in,
    input sign,
    output [31:0]o
);
assign o=sign?{{(33-WIDTH){1'b0}},in}:{{(33-WIDTH){in[WIDTH-1]}},in};

endmodule