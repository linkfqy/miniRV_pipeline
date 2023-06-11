// 理想流水线，跳转相关信号均悬空
module mini_rv(
    input clk,
    input rst_n,
    input  [31:0] irom_inst,
    output [31:0] irom_adr,
    input  [31:0] dram_rd,
    output        dram_we,
    output [31:0] dram_adr,
    output [31:0] dram_wdin,
    // debug signal
    output        wb_have_inst,
    output [31:0] wb_pc,
    output        wb_ena,
    output [4:0]  wb_reg,
    output [31:0] wb_value
);

// --------------------IF BEGIN--------------------
wire [31:0] IF_pc_pc;
wire [31:0] IF_npc_pc4;

IF IF_u (
    .clk(clk),
    .rst_n(rst_n),
    .pc_pc(IF_pc_pc),
    .npc_pc4(IF_npc_pc4),
    .npc_op(2'b00),  //理想流水线默认取pc+4
    .npc_imm(),
    .npc_adrj()
);
// --------------------IF END--------------------
reg [31:0] IF_ID_pc_pc;
reg [31:0] IF_ID_npc_pc4;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        IF_ID_pc_pc <= 0;
        IF_ID_npc_pc4 <= 0;
    end else begin
        IF_ID_pc_pc <= IF_pc_pc;
        IF_ID_npc_pc4 <= IF_npc_pc4;
    end
end
// --------------------ID BEGIN--------------------
assign irom_adr = IF_ID_pc_pc;

wire [31:0] ID_sext_ext;
wire        ID_rf_we;
wire [ 4:0] ID_rf_adr;
wire [31:0] ID_rf_rd1;
wire [31:0] ID_rf_rd2;
wire        ID_alub_sel;
wire [ 3:0] ID_alu_op;
wire        ID_dram_we;
wire [ 1:0] ID_wd_sel;

wire [31:0] WB_rf_wd;
wire        WB_rf_we;
wire [ 4:0] WB_rf_adr;

ID ID_u(
    .clk(clk),
    .rst_n(rst_n),
    .irom_inst(irom_inst),
    .sext_ext(ID_sext_ext),
    .rf_wd_from_wb(WB_rf_wd),   //从WB阶段传来
    .rf_we_from_wb(WB_rf_we),   //从WB阶段传来
    .rf_adr_from_wb(WB_rf_adr), //从WB阶段传来
    .rf_we(ID_rf_we),
    .rf_adr(ID_rf_adr),
    .rf_rd1(ID_rf_rd1),
    .rf_rd2(ID_rf_rd2),
    .alu_comp(),
    .npc_op(),
    .alub_sel(ID_alub_sel),
    .alu_op(ID_alu_op),
    .dram_we(ID_dram_we),
    .wd_sel(ID_wd_sel)
);
// --------------------ID END--------------------
reg [31:0] ID_EX_sext_ext;
reg        ID_EX_rf_we;
reg [ 4:0] ID_EX_rf_adr;
reg [31:0] ID_EX_rf_rd1;
reg [31:0] ID_EX_rf_rd2;
reg        ID_EX_alub_sel;
reg [ 3:0] ID_EX_alu_op;
reg        ID_EX_dram_we;
reg [ 1:0] ID_EX_wd_sel;
reg [31:0] ID_EX_npc_pc4;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ID_EX_sext_ext <= 0;
        ID_EX_rf_we <= 0;
        ID_EX_rf_adr <= 0;
        ID_EX_rf_rd1 <= 0;
        ID_EX_rf_rd2 <= 0;
        ID_EX_alub_sel <= 0;
        ID_EX_alu_op <= 0;
        ID_EX_dram_we <= 0;
        ID_EX_wd_sel <= 0;
        ID_EX_npc_pc4 <= 0;
    end else begin
        ID_EX_sext_ext <= ID_sext_ext;
        ID_EX_rf_we <= ID_rf_we;
        ID_EX_rf_adr <= ID_rf_adr;
        ID_EX_rf_rd1 <= ID_rf_rd1;
        ID_EX_rf_rd2 <= ID_rf_rd2;
        ID_EX_alub_sel <= ID_alub_sel;
        ID_EX_alu_op <= ID_alu_op;
        ID_EX_dram_we <= ID_dram_we;
        ID_EX_wd_sel <= ID_wd_sel;
        ID_EX_npc_pc4 <= IF_ID_npc_pc4;
    end
end
// --------------------EX BEGIN--------------------
wire [31:0] EX_alu_c;

EX EX_u(
    .rf_rd1(ID_EX_rf_rd1),
    .rf_rd2(ID_EX_rf_rd2),
    .sext_ext(ID_EX_sext_ext),
    .alub_sel(ID_EX_alub_sel),
    .alu_op(ID_EX_alu_op),
    .alu_c(EX_alu_c),
    .alu_comp()
);
// --------------------EX END--------------------
reg  [31:0] EX_MEM_alu_c;
reg         EX_MEM_rf_we;
reg  [ 4:0] EX_MEM_rf_adr;
reg         EX_MEM_dram_we;
reg  [ 1:0] EX_MEM_wd_sel;
reg  [31:0] EX_MEM_npc_pc4;
reg  [31:0] EX_MEM_rf_rd2;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        EX_MEM_alu_c    <= 0;
        EX_MEM_rf_we    <= 0;
        EX_MEM_rf_adr   <= 0;
        EX_MEM_dram_we  <= 0;
        EX_MEM_wd_sel   <= 0;
        EX_MEM_npc_pc4  <= 0;
        EX_MEM_rf_rd2   <= 0;
    end else begin
        EX_MEM_alu_c    <= EX_alu_c;
        EX_MEM_rf_we    <= ID_EX_rf_we;
        EX_MEM_rf_adr   <= ID_EX_rf_adr;
        EX_MEM_dram_we  <= ID_EX_dram_we;
        EX_MEM_wd_sel   <= ID_EX_wd_sel;
        EX_MEM_npc_pc4  <= ID_EX_npc_pc4;
        EX_MEM_rf_rd2   <= ID_EX_rf_rd2;
    end
end
// --------------------MEM BEGIN--------------------
assign dram_we = EX_MEM_dram_we;
assign dram_adr = EX_MEM_alu_c;
assign dram_wdin = EX_MEM_rf_rd2;

wire [31:0] MEM_dram_rd = dram_rd;
// --------------------MEM END--------------------
reg  [31:0] MEM_WB_dram_rd;
reg         MEM_WB_rf_we;
reg  [31:0] MEM_WB_rf_adr;
reg  [31:0] MEM_WB_alu_c;
reg  [31:0] MEM_WB_npc_pc4;
reg  [ 1:0] MEM_WB_wd_sel;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        MEM_WB_dram_rd  <= 0;
        MEM_WB_rf_we    <= 0;
        MEM_WB_rf_adr   <= 0;
        MEM_WB_alu_c    <= 0;
        MEM_WB_npc_pc4  <= 0;
        MEM_WB_wd_sel   <= 0;
    end else begin
        MEM_WB_dram_rd  <= MEM_dram_rd;
        MEM_WB_rf_we    <= EX_MEM_rf_we;
        MEM_WB_rf_adr   <= EX_MEM_rf_adr;
        MEM_WB_alu_c    <= EX_MEM_alu_c;
        MEM_WB_npc_pc4  <= EX_MEM_npc_pc4;
        MEM_WB_wd_sel   <= EX_MEM_wd_sel;
    end
end
// --------------------WB BEGIN--------------------
assign WB_rf_we = MEM_WB_rf_we;
assign WB_rf_adr = MEM_WB_rf_adr;

WB WB_u (
    .wd_sel(MEM_WB_wd_sel),
    .npc_pc4(MEM_WB_npc_pc4),
    .alu_c(MEM_WB_alu_c),
    .dram_rd(MEM_WB_dram_rd),
    .rf_wd(WB_rf_wd)
);
// --------------------WB END--------------------

endmodule