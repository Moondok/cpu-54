module controller ( // 30 control signals
    input clk,
    input rst,
    input [53:0] decoded_instr,
    input zero,
    input Rs_signal,
    input busy,
    output zin,   //ok
    output zout,  //ok
    output pc_ena, //pc register can be written  //ok
    output npc_in,  //ok
    output decode_ena, //ok
    output ir_in,
    output regfile_w, //ok
    output [1:0] ref_waddr_signal,
    output [2:0] ref_wdata_signal,
    output [1:0] npc_input_signal,
    output ext5_input_signal,   //ok
    output extend16_signal1, //for imm extend  //ok
    output extend16_signal2, //for lh instr
    output extend8_signal1, //for lb instr
    output [1:0] dmem2ref_signal,
    output MDR_in,
    output [1:0] operand1_signal,  //ok
    output [1:0] operand2_signal,  //ok
    output hi_ena,
    output lo_ena,
    output [1:0] hi_input_signal,
    output [1:0] lo_input_signal,
    output [1:0] store_format_signal, //ok
    output [4:0] cp0_cause,   //ok
    output cp0_ena,           //ok
    output div_start,
    output divu_start,
    output mul_start,
    output mulu_start,

    output [3:0] alu_control

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

    // 4 periods: 24 simple algorithmic instructions   ,  teq 
      else 
        states=state2;
    end

    else if(states==state2)
    begin
      states=state4; //default transfer to states 4, cuz most instructions are 4 periods
    end

    else if(states==state3)
    begin
      
    end

    else if(states==state4)
        states=state0;
        
    
    
end
assign zin=!rst&&(
  ((states[0]||states[2])&&(decoded_instr[15:0]||decoded_instr[23:17]||decoded_instr[28:27]))  //24 simple algorithmic instructions,z can be write in the 1st or 3rd period
  

);

assign zout=!rst&&(
  ((states[1]||states[4])&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]))  //24 simple algorithmic instructions, z should be read in the 2nd or the last period
);

assign npc_in=!rst&&(
  (states[1]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]))  //24 simple algorithmic instructions
  ||
  (states[4]&&(decoded_instr[50]||decoded_instr[51]||decoded_instr[53]||(decoded_instr[52]&&zero))) // eret break syscall teq
);

assign npc_input_signal[0]=
assign npc_input_signal[1]=

assign pc_ena=states[0]&!rst;

// 10:pc   01: ext5(6 shift instrs)
assign operand1_signal[0]=(
  states[2]&&(decoded_instr[15:10])
);
assign operand1_signal[1]=(
  states[0]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27])  //pc+4
);

// 11:4  01: imm
assign operand2_signal[0]=(
  (states[0]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27])) //pc+4
  || 
  (states[2]&&(decoded_instr[22:17]||decoded_instr[28:27])) // extend 16 bit imm to alu
);
assign operand2_signal[1]=(
  states[0]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27])  //pc+4
);


assign ext5_input_signal=decoded_instr[13]||decoded_instr[14]||decoded_instr[15]; // sllv, srlv, srav , extend Rs value

assign ir_in=!rst&states[0];
assign decode_ena=!rst&states[0];

//24 simple instructions      mft0
assign regfile_w=!rst&&(
  states[4]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[44])
);

//00:Rd  01:Rt //10:$31
assign ref_waddr_signal[0]=decoded_instr[22:17]||decoded_instr[28:27]; //addi slti lui...
assign ref_waddr_signal[1]=decoded_instr[31]||decoded_instr[36]; //jal jalr 

//00: z_value
assign ref_wdata_signal[0]=
assign ref_wdata_signal[1]=
assign ref_wdata_signal[2]=

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


assign cp0_cause=decoded_instr[51]?SYSCALL:(decoded_instr[52]?TEQ:(decoded_instr[53]?BREAK:5'b00000));

assign alu_control[0]=
assign alu_control[1]=
assign alu_control[2]=
assign aluc_control[3]=

endmodule //controller