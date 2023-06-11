module display (
    input clk_i,
    input rst_n,
    input [31:0] dig,
    input dig_we,
    output reg [7:0] dig_en,
    output dig_ca,
    output dig_cb,
    output dig_cc,
    output dig_cd,
    output dig_ce,
    output dig_cf,
    output dig_cg,
    output dig_dp
);

assign dig_dp = 1'b1;

wire clk_display;

divider divider_u (
    .clk_i(clk_i),
    .rst_n(rst_n),
    .clk_o(clk_display)
);

wire cnt_end = (dig_en==8'b0111111);
always @(posedge clk_display or negedge rst_n) begin
    if (~rst_n) begin
        dig_en<=8'b11111110;
    end
    else if (cnt_end) begin
        dig_en<=8'b11111110;
    end
    else begin
        dig_en<={dig_en[6:0],dig_en[7]};
    end
end

reg [31:0] buffer;  //缓存32位二进制值
reg [3:0] dig_now;  //当前刷新位上的数字

always @(posedge clk_i or negedge rst_n) begin
    if (~rst_n) buffer <= 0;
    else if (dig_we) buffer <= dig;
end

always @(*) begin
    case (dig_en)
        8'b11111110: dig_now = buffer[3:0];
        8'b11111101: dig_now = buffer[7:4];
        8'b11111011: dig_now = buffer[11:8];
        8'b11110111: dig_now = buffer[15:12];
        8'b11101111: dig_now = buffer[19:16];
        8'b11011111: dig_now = buffer[23:20];
        8'b10111111: dig_now = buffer[27:24];
        8'b01111111: dig_now = buffer[31:28];
        default: dig_now = 4'd0;
    endcase
end

reg [6:0] digs;
assign dig_ca = digs[0];
assign dig_cb = digs[1];
assign dig_cc = digs[2];
assign dig_cd = digs[3];
assign dig_ce = digs[4];
assign dig_cf = digs[5];
assign dig_cg = digs[6];

always @(*) begin
    if (~rst_n) digs <= 7'b1111111;
    else begin
        case (dig_now)
            4'h0: digs<=7'b1000000;
            4'h1: digs<=7'b1111001;
            4'h2: digs<=7'b0100100;
            4'h3: digs<=7'b0110000;
            4'h4: digs<=7'b0011001;
            4'h5: digs<=7'b0010010;
            4'h6: digs<=7'b0000010;
            4'h7: digs<=7'b1111000;
            4'h8: digs<=7'b0000000;
            4'h9: digs<=7'b0011000;
            4'ha: digs<=7'b0001000;
            4'hb: digs<=7'b0000011;
            4'hc: digs<=7'b0100111;
            4'hd: digs<=7'b0100001;
            4'he: digs<=7'b0000110;
            4'hf: digs<=7'b0001110;
            default: digs<=7'b0;
        endcase
    end
end

endmodule