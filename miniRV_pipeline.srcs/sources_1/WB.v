module WB (
    input   [1:0]   wd_sel,
    input   [31:0]  npc_pc4,
    input   [31:0]  alu_c,
    input   [31:0]  dram_rd,
    output  [31:0]  rf_wd
);

assign rf_wd = (wd_sel==2'b00)?npc_pc4:
               (wd_sel==2'b01)?alu_c:dram_rd;

endmodule