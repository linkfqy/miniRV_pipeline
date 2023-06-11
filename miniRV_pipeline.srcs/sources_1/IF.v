module IF (
    input clk,
    input rst_n,
    output [31:0] pc_pc,
    output [31:0] npc_pc4,
    input [1:0] npc_op,
    input [31:0] npc_imm,
    input [31:0] npc_adrj
);

wire [31:0] npc_npc;

npc npc_u (
    .pc(pc_pc),
    .imm(npc_imm),
    .adrj(npc_adrj),
    .op(npc_op),
    .pc4(npc_pc4),
    .npc(npc_npc)
);

pc pc_u (
    .clk(clk),
    .rst_n(rst_n),
    .din(npc_npc),
    .pc(pc_pc)
);

endmodule