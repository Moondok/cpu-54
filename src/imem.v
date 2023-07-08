module imem(
    input [10:0] a,
    output [31:0] spo
    
);
reg [31:0] mem [1024:0];

initial
begin
  mem[0]=32'h3c1d1001;
  mem[1]=32'h37bd0004;

end

assign spo=mem[a];

endmodule //imem