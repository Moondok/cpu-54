module hilo (
    input clk,
    input rst,
    input wena,
    input [31:0] wdata,
    output [31:0] rdata

    
);
reg [31:0] data;
always @(negedge clk) begin
    if(rst)
        data<=32'd0;
    else if(wena)
        data<=wdata;

end

assign rdata=data;

endmodule //hilo