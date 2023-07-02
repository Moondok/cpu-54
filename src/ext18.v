module ext18 (
    input [17:0] imm, // immediate number read from instruction [15:0]
    output [31:0] o
);
// this module is for instructio bne and beq , we do signed-extend
assign o={{14{imm[17]}},imm};

endmodule //ext18