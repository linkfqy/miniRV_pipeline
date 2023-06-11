module pc(
    input clk,
    input rst_n,
    input [31:0] din,
    output reg [31:0] pc
);

reg last_rst_n;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n || ~last_rst_n) pc<=32'b0;  // 异步复位后，PC变为0x00000000
    else if (clk) pc<=din;
    last_rst_n <= rst_n;
end

endmodule