module ex16 (
    input [15:0] in_data,
    input signal,
    output [31:0] o_data
    
);
// this module can support both signed extend and unsigned extend
assign o_data=signal? { {16{1'b0}},in_data}:{ {16{in_data[15]}},in_data};

endmodule //ex16