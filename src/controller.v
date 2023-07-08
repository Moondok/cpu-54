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
    output ir_in,     //ok
    output regfile_w, //ok
    output [1:0] ref_waddr_signal,//ok
    output [2:0] ref_wdata_signal,//ok
    output [1:0] npc_input_signal, //ok
    output ext5_input_signal,   //ok
    output extend16_signal1, //for imm extend  //ok
    output extend16_signal2, //for lh instr  //ok
    output extend8_signal1, //for lb instr   //ok
    output [1:0] dmem2ref_signal,  //ok
    output MDR_in, //ok
    output [1:0] operand1_signal,  //ok
    output [1:0] operand2_signal,  //ok
    output dmem_w, //ok
    output dmem_r, //ok
    output hi_ena, //ok
    output lo_ena, //ok
    output [1:0] hi_input_signal, 
    output [1:0] lo_input_signal,
    output [1:0] store_format_signal, //ok
    output [4:0] cp0_cause,   //ok
    output cp0_ena,           //ok
    output div_start,     //ok
    output divu_start,    //ok
    output mul_start,     //ok
    output mulu_start,    //ok

    output [3:0] alu_control

);

reg [4:0] next_state=state0;  // kick up the execution

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
        next_state<=state0;
    end
    else 
    begin
      states<=next_state;
      if(next_state==state0) // unconditional jump from state0 to state1 
        next_state=state1;

      else if(next_state==state1)//instr[16](jr),directly to state0
      begin
        if(decoded_instr[16]==1'b1) //jr
          next_state=state0;

      //3 periods: mtc0 mfc0 eret break syscall j mthi mtlo mfhi mflo div,divu mul mulu clz
        else if(decoded_instr[44]||decoded_instr[45]||decoded_instr[50]||decoded_instr[51]||decoded_instr[53]||decoded_instr[29]||decoded_instr[46]||decoded_instr[47]||decoded_instr[48]||decoded_instr[49]||decoded_instr[36:33]||decoded_instr[31])
          next_state=state4;
      
      //begz 3 or 4 periods
        else if(decoded_instr[37]) //Rs>=0
        begin
          if(Rs_signal==1'b1)
            next_state<=state3;
          else
            next_state<=state4;
        end
          
        

      // 4 periods: 24 simple algorithmic instructions  , s*,  teq 
      // 5 periods : l*
        else 
          next_state=state2;
      end

      else if(next_state==state2)
      begin
        if(decoded_instr[23]||decoded_instr[38]||decoded_instr[39]||decoded_instr[40]||decoded_instr[41]) // for l* instructions, we need 5 periods 
          next_state<=state3;

        // bne bnq
        else if(decoded_instr[25]&&zero)
          next_state<=state3; // if Rs==Rt to state3 to perform add
        else if(decoded_instr[26&&!zero])
          next_state<=state3; // if Rs!=Rt to state3 to perform add
        
        else
          next_state<=state4; //default transfer to states 4, cuz most instructions are 4 periods
      end

      else if(next_state==state3)
      begin
        next_state<=state4;
      end

      else if(next_state==state4)
      begin
        if(decoded_instr[36:33]&&busy) // div ,divu mul mulu : only whe calculation is done , we change state
          next_state=state4; 
        else
          next_state=state0;
      end
      
    end
    
end
assign zin=!rst&&(
  ((states[0]||states[2])&&(decoded_instr[15:0]||decoded_instr[23:17]||decoded_instr[28:27]||decoded_instr[24:23]||decoded_instr[43:38]))  //24 simple algorithmic instructions  l* s*  ,z can be write in the 1st or 3rd period
  ||
  (states[0]&&(decoded_instr[45:44]||decoded_instr[53:50]||decoded_instr[49:46]||decoded_instr[35:32]||decoded_instr[31]||decoded_instr[26:25]||decoded_instr[37])) //cp0(6 instrs), hi lo(4 instrs) clz
  ||
  (states[3]&&(decoded_instr[26:25]||decoded_instr[37]))// bne beq begz
);

assign zout=!rst&&(
  ((states[1]||states[4])&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[24:23]||decoded_instr[43:38]))  //24 simple algorithmic instructions, l* s* z should be read in the 2nd or the last period
  ||
  (states[2]&&(decoded_instr[30]||decoded_instr[36]))// for jal and jalr , to reserve the spot
  ||
  (states[3]&&(decoded_instr[23]||decoded_instr[38]||decoded_instr[39]||decoded_instr[40]||decoded_instr[41])) // l* , let the read addr out
  ||
  (states[4]&&(decoded_instr[24]||decoded_instr[42]||decoded_instr[43]||decoded_instr[26]||decoded_instr[25]||decoded_instr[37])) //s*, let the write dmem addr out  , bne beq begz
  ||
  (states[1]&&(decoded_instr[45:44]||decoded_instr[53:50]||decoded_instr[49:46]||decoded_instr[35:32]||decoded_instr[31]||decoded_instr[26:25]||decoded_instr[37])) //cp0(6 instrs)  , hi lo(4 instrs) clz

);

assign npc_in=!rst&&(
  (states[1]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[16]||decoded_instr[24:23]||decoded_instr[43:38]||decoded_instr[45:44]||decoded_instr[53:50]||decoded_instr[49:46]||decoded_instr[35:32]||decoded_instr[31]||decoded_instr[26:25]||decoded_instr[37]))  //24 simple algorithmic instructions, jr , l*
  ||
  (states[4]&&(decoded_instr[50]||decoded_instr[51]||decoded_instr[53]||(decoded_instr[52]&&zero))||decoded_instr[29]||decoded_instr[30]||decoded_instr[36]||decoded_instr[26]||decoded_instr[25]||decoded_instr[37]) // eret break syscall teq   j   jal  jalr
);

//01 Rs_value,for jr,jalr      10:joint for  j, jal     11: exc_addr
assign npc_input_signal[0]=(
  (states[1]&&decoded_instr[16])  //jr
  ||
  (states[4]&&(decoded_instr[36]||decoded_instr[50]||decoded_instr[51]||decoded_instr[53]||(decoded_instr[52]&&zero)))  //jalr  cp0(4 instrs)
  
);
assign npc_input_signal[1]=(
  (states[4]&&(decoded_instr[29]||decoded_instr[30]||decoded_instr[50]||decoded_instr[51]||decoded_instr[53]||(decoded_instr[52]&&zero))) // j jal cp0(4 instrs)
);

assign pc_ena=states[0]&!rst;

// 10:pc   01: ext5(6 shift instrs)
assign operand1_signal[0]=(
  states[2]&&(decoded_instr[15:10])
);
assign operand1_signal[1]=(
  states[0]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[24:23]||decoded_instr[43:38]||decoded_instr[45:44]||decoded_instr[53:50]||decoded_instr[49:46]||decoded_instr[35:32]||decoded_instr[31]||decoded_instr[26:25]||decoded_instr[37])  //pc+4
  ||
  states[3]&&(decoded_instr[26]||decoded_instr[25]||decoded_instr[37])
);

// 11:4  01: imm   10 :ext 18
assign operand2_signal[0]=(
  (states[0]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[24:23]||decoded_instr[43:38]||decoded_instr[45:44]||decoded_instr[53:50]||decoded_instr[49:46]||decoded_instr[35:32]||decoded_instr[31]||decoded_instr[26:25]||decoded_instr[37])) //pc+4
  || 
  (states[2]&&(decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[24:23]||decoded_instr[43:38])) // extend 16 bit imm to alu
);
assign operand2_signal[1]=(
  states[0]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[24:23]||decoded_instr[43:38]||decoded_instr[45:44]||decoded_instr[53:50]||decoded_instr[49:46]||decoded_instr[35:32]||decoded_instr[31]||decoded_instr[26:25]||decoded_instr[37])  //pc+4
  ||
  states[3]&&(decoded_instr[26]||decoded_instr[25]||decoded_instr[37])
);


assign ext5_input_signal=decoded_instr[13]||decoded_instr[14]||decoded_instr[15]; // sllv, srlv, srav , extend Rs value

assign ir_in=!rst&states[0];
assign decode_ena=!rst&states[0];

// l*  : read the data out in the 4th period
assign dmem_r=states[3]&&(decoded_instr[23]||decoded_instr[38]||decoded_instr[39]||decoded_instr[40]||decoded_instr[41]);
assign MDR_in=states[3]&&(decoded_instr[23]||decoded_instr[38]||decoded_instr[39]||decoded_instr[40]||decoded_instr[41]);

//s* : write in the dmem in the 4th(last) period
assign dmem_w=states[4]&&(decoded_instr[24]||decoded_instr[42]||decoded_instr[43]);

//24 simple instructions      mft0 jal jalr  l* mfhi mflo mul
assign regfile_w=!rst&&(
  (states[4]&&(decoded_instr[15:0]||decoded_instr[22:17]||decoded_instr[28:27]||decoded_instr[44]||decoded_instr[23]||decoded_instr[41:38]||decoded_instr[46]||decoded_instr[48]||decoded_instr[34]||decoded_instr[31]))
  ||
  (states[2]&&(decoded_instr[30]||decoded_instr[36]))   // note that Z reg stores pc+4 then
);

//00:Rd  01:Rt //10:$31
assign ref_waddr_signal[0]=decoded_instr[22:17]||decoded_instr[28:27]; //addi slti lui...
assign ref_waddr_signal[1]=decoded_instr[30]||decoded_instr[36]; //jal jalr 

//000: z_value //001 dmem2ref //010: clz_value  //101: cp0_data  //011: hi_data  //100: lo_data //110 :res_mul[31:0]
assign ref_wdata_signal[0]=decoded_instr[23]||decoded_instr[38]||decoded_instr[39]||decoded_instr[40]||decoded_instr[41]||decoded_instr[44]||decoded_instr[46];
assign ref_wdata_signal[1]=decoded_instr[46]||decoded_instr[34]||decoded_instr[31];
assign ref_wdata_signal[2]=decoded_instr[44]||decoded_instr[48]||decoded_instr[34];

// addi addiu slti sltiu lw lh lb lhu lbu sw sb sh
assign extend16_signal1=decoded_instr[17]||decoded_instr[18]||decoded_instr[27]||decoded_instr[28]||decoded_instr[24:23]||decoded_instr[43:38];

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


assign hi_ena=states[4]&&(decoded_instr[47]||decoded_instr[33]||decoded_instr[32]||decoded_instr[35]);
assign lo_ena=states[4]&&(decoded_instr[49]||decoded_instr[33]||decoded_instr[32]||decoded_instr[35]);

// note that the start signal in div/divu and mul/mulu are different
assign div_start=states[1]&&decoded_instr[33];
assign divu_start=states[1]&&decoded_instr[32];
assign mul_start=decoded_instr[34]; // through multiple cycles
assign mulu_start=decoded_instr[35]; // through multiple cycles

//01 res_r  10 res_ru  11 multu[63:32]
assign hi_input_signal[0]=decoded_instr[33]||decoded_instr[35];
assign hi_input_signal[1]=decoded_instr[32]||decoded_instr[35];

//01 res_q 10 res_qu  11 multu[31:0]
assign lo_input_signal[0]=decoded_instr[33]||decoded_instr[35];
assign lo_input_signal[1]=decoded_instr[32]||decoded_instr[35];


assign alu_control[0]=(
  (states[2]&&(decoded_instr[1]||decoded_instr[18]||decoded_instr[3]||decoded_instr[5]||decoded_instr[20]||decoded_instr[7]||decoded_instr[9]||decoded_instr[28]||decoded_instr[11]||decoded_instr[14]||decoded_instr[22]))
);

assign alu_control[1]=(
  (states[1]&&(decoded_instr[26]||decoded_instr[25]))
  ||
  (states[2]&&(decoded_instr[2]||decoded_instr[3]||decoded_instr[6]||decoded_instr[21]||decoded_instr[7]||decoded_instr[10]||decoded_instr[13]||decoded_instr[11]||decoded_instr[14]||decoded_instr[52]))

);

assign alu_control[2]=(
  (states[2]&&(decoded_instr[4]||decoded_instr[19]||decoded_instr[5]||decoded_instr[20]||decoded_instr[6]||decoded_instr[21]||decoded_instr[7]||decoded_instr[12]||decoded_instr[15]||decoded_instr[22]))
);

assign alu_control[3]=(
  (states[2]&&(decoded_instr[8]||decoded_instr[27]||decoded_instr[9]||decoded_instr[28]||decoded_instr[10]||decoded_instr[13]||decoded_instr[11]||decoded_instr[14]||decoded_instr[12]||decoded_instr[15]||decoded_instr[22]))
);

endmodule //controller