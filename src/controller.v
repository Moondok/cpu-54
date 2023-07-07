module controller (
    input clk,
    input rst,
    input [53:0] decoded_instr,
    input zero,
    input Rs_signal,
    input busy,
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
    output [1:0] store_format_signal,
    output [4:0] cp0_cause,
    output cp0_ena,
    output div_start,
    output divu_start,
    output mul_start,
    output mulu_start

);

localparam state0=1;
localparam state1=2;
localparam state2=4;
localparam state3=8;
localparam state4=16;

localparam TEQ=5'b01101;
localparam BREAK=5'b01001;
localparam SYSCALL=5'b01000;


reg [4:0] states; //each bit stands for one state, one-hot coding
always @(posedge clk) 
begin
    if(rst)
    begin
        states<=5'b0;
    end

    else if(states==state0) // unconditional jump from state0 to state1
        states=state1;

    else if(states==state1)//instr[16](jr),directly to state0
    begin
      if(decoded_instr[16]==1'b1) //jr
        states=state0;

    //3 periods: mtc0 mfc0 eret break syscall
      else if(decoded_instr[44]||decoded_instr[45]||decoded_instr[50]||decoded_instr[51]||decoded_instr[53])
        states=state4;

    // 4 periods: teq 
      else if(decoded_instr[52]) 
        states=state2;
    end

    else if(states==state2)
    begin
      states=state4; //default transfer to states 4, cuz most instructions are 4 periods
    end

    else if(states==state4)
        states=state0;
        
    
    
end
assign zin=states[0]&!rst;
assign zout=states[1]&!rst;
assign npc_in=!rst&states[1];
assign pc_ena=states[0]&!rst;
assign ir_in=!rst&states[0];
assign decode_ena=!rst&states[0];

//add   mft0
assign regfile_w=!rst&states[4]&(decoded_instr[0]||decoded_instr[44]);

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

assign cp0_ena=!rst&&(states[4]&&(decoded_instr[50]||decoded_instr[51]||decoded_instr[53]||(decoded_instr[52]&&zero)||decoded_instr[45]));

assign npc_in=!rst&&(states[4]&&(decoded_instr[50]||decoded_instr[51]||decoded_instr[53]||(decoded_instr[52]&&zero)));

assign cp0_cause=decoded_instr[51]?SYSCALL:(decoded_instr[52]?TEQ:(decoded_instr[53]?BREAK:5'b00000));



endmodule //controller