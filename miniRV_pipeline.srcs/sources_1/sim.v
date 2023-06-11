`timescale 1ns / 1ps
module sim();
    // input
    reg fpga_clk = 0;
    // output
    wire clk_lock;
    wire pll_clk;
    wire cpu_clk;

    always #5 fpga_clk = ~fpga_clk;

    cpuclk UCLK (
        .clk_in1    (fpga_clk),
        .locked     (clk_lock),
        .clk_out1   (pll_clk)
    );

    assign cpu_clk = pll_clk & clk_lock;

    wire clk = cpu_clk;
    reg rst_n,flg;

    initial begin
        rst_n = 1;
        flg = 1;
    end

    always @(posedge clk) begin
        if (flg) begin
            flg <= 0;
            rst_n <= 0;
        end else rst_n <= 1;
    end

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
        .wb_have_inst(),
        .wb_pc(),
        .wb_ena(),
        .wb_reg(),
        .wb_value()
    );

    inst_mem imem(
        .a(irom_adr[15:2]),  // 14位按字寻址
        .spo(irom_inst)
    );

    data_mem dmem(
        .clk(clk),  // dram异步读取
        .a(dram_adr[15:2]),
        .we(dram_we),
        .d(dram_wdin),
        .spo(dram_rd)
    );
endmodule
