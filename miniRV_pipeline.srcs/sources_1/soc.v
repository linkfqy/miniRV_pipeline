module soc (
    input  clk_i,
    input  rst_i,
    input  [23:0] switch,
    output [7:0] dig_en,
    output dig_ca,
    output dig_cb,
    output dig_cc,
    output dig_cd,
    output dig_ce,
    output dig_cf,
    output dig_cg,
    output dig_dp,
    output [23:0] led
);

wire rst_n = !rst_i;
wire clk_out1;
wire clk_locked;
wire clk = clk_out1 & clk_locked;

cpuclk cpuclk_u (
    .clk_in1(clk_i),
    .locked(clk_locked),
    .clk_out1(clk_out1)
);

wire [31:0] irom_adr;
wire [31:0] irom_inst;
wire [31:0] bus_adr;
wire [31:0] bus_wdin;
wire [31:0] bus_rd;
wire bus_we;

mini_rv mini_rv_u (
    .clk(clk),
    .rst_n(rst_n),
    .irom_inst(irom_inst),
    .dram_rd(bus_rd),
    .irom_adr(irom_adr),
    .dram_we(bus_we),
    .dram_adr(bus_adr),
    .dram_wdin(bus_wdin),
    .wb_have_inst(),
    .wb_pc(),
    .wb_ena(),
    .wb_reg(),
    .wb_value()
);

prgrom irom_u (
    .a(irom_adr[15:2]),  // 14位按字寻址
    .spo(irom_inst)
);

wire [13:0] dram_adr;
wire [31:0] dram_wdin;
wire dram_we;
wire [31:0] dram_rd;
wire [31:0] dig;
wire dig_we;

bus bus_u (
    .clk(clk_i),
    .adr(bus_adr),
    .wdin(bus_wdin),
    .we(bus_we),
    .rd(bus_rd),
    .dram_adr(dram_adr),
    .dram_wdin(dram_wdin),
    .dram_we(dram_we),
    .dram_rd(dram_rd),
    .led(led),
    .switch(switch),
    .dig(dig),
    .dig_we(dig_we)
);

dram dram_u (
    .clk(clk),  // dram异步读取
    .a(dram_adr),
    .we(dram_we),
    .d(dram_wdin),
    .spo(dram_rd)
);

display display_u (
    .clk_i(clk),
    .rst_n(rst_n),
    .dig(dig),
    .dig_we(dig_we),
    .dig_en(dig_en),
    .dig_ca(dig_ca),
    .dig_cb(dig_cb),
    .dig_cc(dig_cc),
    .dig_cd(dig_cd),
    .dig_ce(dig_ce),
    .dig_cf(dig_cf),
    .dig_cg(dig_cg),
    .dig_dp(dig_dp)
);

endmodule