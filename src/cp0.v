module CP0(
input clk,
input rst,
input mfc0, // CPU instruction is Mfc0
input mtc0, // CPU instruction is Mtc0
input [31:0]pc,
input [4:0] Rd, // Specifies Cp0 register
input [31:0] wdata, // Data from GP register to replace CP0 register
input exception,
input eret, // Instruction is ERET (Exception Return)
input [4:0]cause,
input intr,
output [31:0] rdata, // Data from CP0 register for GP register
output [31:0] status,
// output reg timer_int,
output [31:0]exc_addr // Address for PC at the beginning of an exception
);

// 3 tags representing reasons for abnormalities
localparam TEQ=5'b01101;
localparam BREAK=5'b01001;
localparam SYSCALL=5'b01000;

localparam status_reg_pos=12;
localparam cause_reg_pos=13;
localparam epc_reg_pos=14;

always @(posedge clk)// about stuff with edge is pending 
begin
    
end




endmodule