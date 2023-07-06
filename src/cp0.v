module CP0(
input clk,
input rst,
input ena,
input mfc0, // CPU instruction is Mfc0
input mtc0, // CPU instruction is Mtc0
input [31:0]npc,
input [4:0] Rd, // Specifies Cp0 register
input [31:0] wdata, // Data from GP register to replace CP0 register
input exception,
input eret, // Instruction is ERET (Exception Return)
input [4:0]cause,
output [31:0] rdata, // Data from CP0 register for GP register
output reg[31:0]exc_addr // Address for PC at the beginning of an exception
);

// 3 tags representing reasons for interupting
localparam TEQ=5'b01101;
localparam BREAK=5'b01001;
localparam SYSCALL=5'b01000;

localparam status_reg_pos=12;
localparam cause_reg_pos=13;
localparam epc_reg_pos=14;

assign rdata= mfc0? cp0_regs[Rd]:32'bz;

reg [31:0] cp0_regs[31:0] ;
always @(negedge clk)// about stuff with edge is pending 
begin
    if(rst)
    begin
      cp0_regs[status_reg_pos]<=32'd15;
      cp0_regs[0]<=32'b0;
      cp0_regs[1]<=32'b0;
      cp0_regs[2]<=32'b0;
      cp0_regs[3]<=32'b0;
      cp0_regs[4]<=32'b0;
      cp0_regs[5]<=32'b0;
      cp0_regs[6]<=32'b0;
      cp0_regs[7]<=32'b0;
      cp0_regs[8]<=32'b0;
      cp0_regs[9]<=32'b0;
      cp0_regs[10]<=32'b0;
      cp0_regs[11]<=32'b0;
      //cp0_regs[12]<=32'b0;
      cp0_regs[13]<=32'b0;
      cp0_regs[14]<=32'b0;
      cp0_regs[15]<=32'b0;
      cp0_regs[16]<=32'b0;
      cp0_regs[17]<=32'b0;
      cp0_regs[18]<=32'b0;
      cp0_regs[19]<=32'b0;
      cp0_regs[20]<=32'b0;
      cp0_regs[21]<=32'b0;
      cp0_regs[22]<=32'b0;
      cp0_regs[23]<=32'b0;
      cp0_regs[24]<=32'b0;
      cp0_regs[25]<=32'b0;
      cp0_regs[26]<=32'b0;
      cp0_regs[27]<=32'b0;
      cp0_regs[28]<=32'b0;
      cp0_regs[29]<=32'b0;
      cp0_regs[30]<=32'b0;
      cp0_regs[31]<=32'b0;

    end
    else if(ena)
    begin
        if(eret) //exit the interupt
        begin
            cp0_regs[status_reg_pos]<=cp0_regs[status_reg_pos]>>5;
            exc_addr<=cp0_regs[epc_reg_pos];
        end
        else if(mtc0) // write
        begin
            cp0_regs[Rd]<=wdata;
        end
        else if(exception && cp0_regs[status_reg_pos][0]) // interupt is allowed
        begin
            if(cause==SYSCALL)
            begin
              if(cp0_regs[status_reg_pos][1]==1'b1)
              begin
                exc_addr<=32'h00400004;
                cp0_regs[status_reg_pos]<=cp0_regs[status_reg_pos]<<5;
                cp0_regs[epc_reg_pos]<=npc;
                cp0_regs[cause_reg_pos][6:2]<=SYSCALL;
              end
            end
            else if(cause==BREAK)
            begin
              if(cp0_regs[status_reg_pos][2]==1'b1)
              begin
                exc_addr<=32'h00400004;
                cp0_regs[status_reg_pos]<=cp0_regs[status_reg_pos]<<5;
                cp0_regs[epc_reg_pos]<=npc;
                cp0_regs[cause_reg_pos][6:2]<=BREAK;
              end
            end
            else if(cause==TEQ)
            begin
              if(cp0_regs[status_reg_pos][3]==1'b1)
              begin
                exc_addr<=32'h00400004;
                cp0_regs[status_reg_pos]<=cp0_regs[status_reg_pos]<<5;
                cp0_regs[epc_reg_pos]<=npc;
                cp0_regs[cause_reg_pos][6:2]<=TEQ;
              end
            end


        end

    end
        


end




endmodule