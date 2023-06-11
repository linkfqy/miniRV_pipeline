module npc (
    input [31:0] pc,
    input [31:0] imm,  // PC跳转位移
    input [31:0] adrj,  // PC直接跳转地址，由ALU计算得出
    input [1:0] op,
    output [31:0] pc4,
    output reg [31:0] npc
);

assign pc4 = pc+32'd4;
wire [31:0] pc_imm = pc+imm;  // 位移跳转地址

always @(*) begin
    case (op)
        2'b00: npc=pc4;
        2'b01: npc=pc_imm;  // 位移跳转
        2'b10: npc=adrj;  // 直接跳转
        default: npc=pc;  // 未定义行为
    endcase
end

endmodule