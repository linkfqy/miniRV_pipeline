module bus (
    input clk,
    input [31:0] adr,
    input [31:0] wdin,
    input we,
    output reg [31:0] rd,

    output reg [13:0] dram_adr,
    output reg [31:0] dram_wdin,
    output reg dram_we,
    input [31:0] dram_rd,

    output reg [23:0] led,
    input [23:0] switch,
    output reg [31:0] dig,
    output reg dig_we
);

always @(posedge clk) begin
    if (32'h4000<=adr && adr<=32'h7FFF) begin
        rd <= dram_rd;
    end
    else if (adr==32'hFFFFF070 && ~we) begin
        rd <= {8'b0,switch};
    end else begin
        rd <= 0;
    end
end

wire [31:0] adr_temp = adr - 32'h4000;

always @(posedge clk) begin
    if (32'h4000<=adr && adr<=32'h7FFF) begin
        dram_adr <= adr_temp[15:2];
        dram_we <= we;
        dram_wdin <= wdin;
    end else begin
        dram_adr <= 0;
        dram_we <= 0;
        dram_wdin <= 0;
    end
end

always @(posedge clk) begin
    if (adr==32'hFFFFF000 && we) begin
        dig_we <= 1;
        dig <= wdin;
    end else begin
        dig_we <= 0;
        dig <= dig;
    end
end

always @(posedge clk) begin
    if (adr==32'hFFFFF060 && we) begin
        led <= wdin;
    end
end

endmodule