`timescale 1ns / 1ps
`include "sccomp_dataflow.v"

module cpu54_tb();
    reg clk;
    reg reset;
    wire [31:0]pc;
    wire [31:0]inst;
    reg [31:0] pc_pre;
    sccomp_dataflow uut(clk,reset,pc,inst);
    integer file_output;
    integer counter = 0;
    initial 
    begin
        file_output = $fopen("./final_result.txt");
        pc_pre=32'h00000000;
        reset = 1;
        clk = 0;
        #65 reset = 0;
    end
//  initial 
//  begin
//      $readmemh("../tests_data/mips_54_mars_simulate_student_ForWeb.coe", uut.imem_inst.mem,0,8095);
//  end

     always 
     begin
     #30 clk=~clk;
        if(clk==1'b1&&reset==0)
        begin
            if(pc_pre!=pc)
            begin
            //counter = counter+1;
               $fdisplay(file_output,"pc: %h",pc);
               $fdisplay(file_output,"instr: %h",inst);
               //$fdisplay(file_output,"imem: %h",cpu54_tb.uut.imem_inst.mem[0]);
               $fdisplay(file_output,"regfile0: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[0]);
               $fdisplay(file_output,"regfile1: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[1]);
               $fdisplay(file_output,"regfile2: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[2]);
               $fdisplay(file_output,"regfile3: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[3]);
               $fdisplay(file_output,"regfile4: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[4]);
               $fdisplay(file_output,"regfile5: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[5]);
               $fdisplay(file_output,"regfile6: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[6]);
               $fdisplay(file_output,"regfile7: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[7]);
               $fdisplay(file_output,"regfile8: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[8]);
               $fdisplay(file_output,"regfile9: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[9]);
               $fdisplay(file_output,"regfile10: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[10]);
               $fdisplay(file_output,"regfile11: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[11]);
               $fdisplay(file_output,"regfile12: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[12]);
               $fdisplay(file_output,"regfile13: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[13]);
               $fdisplay(file_output,"regfile14: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[14]);
               $fdisplay(file_output,"regfile15: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[15]);
               $fdisplay(file_output,"regfile16: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[16]);
               $fdisplay(file_output,"regfile17: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[17]);
               $fdisplay(file_output,"regfile18: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[18]);
               $fdisplay(file_output,"regfile19: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[19]);
               $fdisplay(file_output,"regfile20: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[20]);
               $fdisplay(file_output,"regfile21: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[21]);
               $fdisplay(file_output,"regfile22: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[22]);
               $fdisplay(file_output,"regfile23: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[23]);
               $fdisplay(file_output,"regfile24: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[24]);
               $fdisplay(file_output,"regfile25: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[25]);
               $fdisplay(file_output,"regfile26: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[26]);
               $fdisplay(file_output,"regfile27: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[27]);
               $fdisplay(file_output,"regfile28: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[28]);
               $fdisplay(file_output,"regfile29: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[29]);
               $fdisplay(file_output,"regfile30: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[30]);
               $fdisplay(file_output,"regfile31: %h",cpu54_tb.uut.sccpu.cpu_ref.array_reg[31]);

               pc_pre=pc;
                
            end
        end
       end

     initial
      begin
          $dumpfile("cpu.vcd");
          $dumpvars;

          #80000;
          $finish;
      end



endmodule
