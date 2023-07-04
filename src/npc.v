module npc (
    input [31:0] data_in,
    input npc_in, //signal for write
    input rst,
    output [31:0] data_out
);

reg [31:0] next_instr_addr;
always @(*) 
begin
    if(rst)
        next_instr_addr<=32'b0;
    else if(npc_in)
        next_instr_addr<=data_in;
    
end

assign data_out=next_instr_addr;


endmodule //npc