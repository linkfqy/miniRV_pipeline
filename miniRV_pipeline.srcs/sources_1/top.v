// 本模块为Trace测试的顶层模块
module top(
    input clk,
    input rst_n,
    output        debug_wb_have_inst,   // WB阶段是否有指令 (对单周期CPU，此flag恒为1)
    output [31:0] debug_wb_pc,          // WB阶段的PC (若wb_have_inst=0，此项可为任意值)
    output        debug_wb_ena,         // WB阶段的寄存器写使能 (若wb_have_inst=0，此项可为任意值)
    output [4:0]  debug_wb_reg,         // WB阶段写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output [31:0] debug_wb_value        // WB阶段写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
);

wire [31:0] irom_adr;
wire [31:0] irom_inst;
wire [31:0] dram_adr;
wire [31:0] dram_wdin;
wire [31:0] dram_rd;
wire dram_we;

mini_rv mini_rv_u (
    .clk(clk),
    .rst_n(rst_n),
    .irom_inst(irom_inst),
    .dram_rd(dram_rd),
    .irom_adr(irom_adr),
    .dram_we(dram_we),
    .dram_adr(dram_adr),
    .dram_wdin(dram_wdin),
    .wb_have_inst(debug_wb_have_inst),
    .wb_pc(debug_wb_pc),
    .wb_ena(debug_wb_ena),
    .wb_reg(debug_wb_reg),
    .wb_value(debug_wb_value)
);

inst_mem imem(
    .a(irom_adr[17:2]),  // 16位按字寻址
    .spo(irom_inst)
);

data_mem dmem(
    .clk(!clk),  // dram异步读取，在时钟下降沿写入
    .a(dram_adr[17:2]),
    .we(dram_we),
    .d(dram_wdin),
    .spo(dram_rd)
);

endmodule