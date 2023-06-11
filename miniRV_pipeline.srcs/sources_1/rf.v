module rf (
    input clk,
    input rst_n,
    input [4:0] rR1,
    input [4:0] rR2,
    input [4:0] wR,
    input [31:0] wD,
    input wE,
    output [31:0] rD1,
    output [31:0] rD2
);

reg [31:0] rg[31:0];

assign rD1 = (rR1==5'b0)?32'b0:rg[rR1];
assign rD2 = (rR2==5'b0)?32'b0:rg[rR2];

integer i;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i=0;i<32;i=i+1) begin
            rg[i]<=32'b0;
        end
    end else
    if (clk) begin
        if (wE) rg[wR]<=wD;
    end
end

endmodule