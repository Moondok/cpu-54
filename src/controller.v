module controller (
    input clk,
    input rst,
    input [53:0] decoded_instr,
    input zero,
    input Rs_signal,
    output zin,
    output zout,
    output pc_ena, //pc register can be written
    output npc_in,
    output decode_ena,
    output ir_in,
    output regfile_w,
    output ref_waddr_signal,
    output extend16_signal1, //for imm extend
    output extend16_signal2, //for lh instr
    output extend8_signal1, //for lb instr
    output [1:0] dmem2ref_signal,
    output MDR_in,
    output MDR_ena,
    output [1:0] store_format_signal
    
    
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
    else if(states==state1&&decoded_instr[16])//instr[16](jr),directly to state0
        states=state0;
    
    
end
assign zin=states[0]&!rst;
assign zout=states[1]&!rst;
assign npc_in=!rst&states[1];
assign pc_ena=states[0]&!rst;
assign ir_in=!rst&states[0];
assign decode_ena=!rst&states[0];
assign regfile_w=!rst&states[4]&(decoded_instr[0]);

// addi addiu slti sltiu 
assign extend16_signal1=decoded_instr[17]||decoded_instr[18]||decoded_instr[27]||decoded_instr[28];

//lh
assign extend16_signal2=decoded_instr[38];

//lb
assign extend8_signal1=decoded_instr[39];

// lhu lh
assign dmem2ref_signal[0]=decoded_instr[38]||decoded_instr[41];
// lbu lb
assign dmem2ref_signal[1]=decoded_instr[39]||decoded_instr[40];

// sh
assign store_format_signal[0]=decoded_instr[43];
// sb
assign store_format_signal[1]=decoded_instr[42];

endmodule //controller