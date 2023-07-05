module controller (
    input clk,
    input rst,
    input [53:0] decoded_instr,
    output zin,
    output zout,
    output pc_ena, //pc register can be written
    output npc_in,
    output decode_ena,
    output ir_in,
    output regfile_w,
    output ref_waddr_signal
    
    
);

localparam state0=1;
localparam state1=2;
localparam state2=4;
localparam state3=8;
localparam state4=16;

reg [4:0] states; //each bit stands for one state, one-hot coding
always @(posedge clk) 
begin
    if(rst)
    begin
        states<=5'b0;
    end
    else if(states==state0) // unconditional jump from state0 to state1
        states=state1;
    
end
assign zin=states[0]&!rst;
assign zout=states[1]&!rst;
assign npc_in=!rst&states[1];
assign pc_ena=states[0]&!rst;
assign ir_in=!rst&states[0];
assign decode_ena=!rst&states[0];
assign regfile_w=!rst&states[4]&(decoded_instr[0]);




endmodule //controller