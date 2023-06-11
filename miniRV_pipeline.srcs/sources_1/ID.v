module ID (
    input clk,
    input rst_n,
    input   [31:0]  irom_inst,
    output  [31:0]  sext_ext,
    input   [31:0]  rf_wd_from_wb,
    input           rf_we_from_wb,
    input   [4:0]   rf_adr_from_wb,
    output          rf_we,
    output  [4:0]   rf_adr,
    output  [31:0]  rf_rd1,
    output  [31:0]  rf_rd2,
    input   [1:0]   alu_comp,
    output  [1:0]   npc_op,
    output          alub_sel,
    output  [3:0]   alu_op,
    output          dram_we,
    output  [1:0]   wd_sel
);

wire [2:0] sext_op;

sext sext_u (
    .din(irom_inst[31:7]),
    .op(sext_op),
    .ext(sext_ext)
);

assign rf_adr = irom_inst[11:7];
rf rf_u (
    .clk(clk),
    .rst_n(rst_n),
    .rR1(irom_inst[19:15]),
    .rR2(irom_inst[24:20]),
    .wR(rf_adr_from_wb),
    .wD(rf_wd_from_wb),
    .wE(rf_we_from_wb),
    .rD1(rf_rd1),
    .rD2(rf_rd2)
);

ctrl ctrl_u (
    .inst({irom_inst[30],irom_inst[14:12],irom_inst[6:0]}),
    .eqlt(alu_comp),
    .npc_op(npc_op),
    .sext_op(sext_op),
    .rf_we(rf_we),
    .alub_sel(alub_sel),
    .alu_op(alu_op),
    .dram_we(dram_we),
    .wd_sel(wd_sel)
);

endmodule