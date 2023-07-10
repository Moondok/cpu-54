`timescale 1ns / 1ps
module joint (
    input [3:0] pc_value,
    input [27:0] jump_value,
    output [31:0] joint_addr
);
assign joint_addr={pc_value,jump_value};

endmodule //joint