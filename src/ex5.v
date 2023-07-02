module ex5 (
    input [4:0] i_shift_num,
    output [31:0] o_shift_num
    
);
assign o_shift_num={{27{1'b0}},i_shift_num};

endmodule //ex5