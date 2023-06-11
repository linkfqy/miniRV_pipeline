module sext (
    input [31:7] din,  // 待扩展输入
    input [2:0] op,  // 立即数扩展类型
    output reg [31:0] ext  // 扩展完成的32位立即数
);

wire sign = din[31];

always @(*) begin
    case (op)
        3'b001: ext={{20{sign}},din[31:20]};  // I型指令符号扩展
        3'b010: ext={{20{sign}},din[31:25],din[11:7]};  // S型指令符号扩展
        3'b011: ext={{20{sign}},din[7],din[30:25],din[11:8],1'b0};  // B型指令符号扩展，低位补1个0
        3'b100: ext={din[31:12],12'b0};  // U型指令低位补零
        3'b101: ext={{12{sign}},din[19:12],din[20],din[30:21],1'b0};  // J型指令符号扩展，低位补1个0
        default: ext=32'b0;  // 未定义行为
    endcase
end

endmodule