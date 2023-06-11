module EX (
    input   [31:0]  rf_rd1,
    input   [31:0]  rf_rd2,
    input   [31:0]  sext_ext,
    input           alub_sel,
    input   [3:0]   alu_op,
    output  [31:0]  alu_c,
    output  [1:0]   alu_comp
);

wire [31:0] alu_b = (alub_sel==0)?rf_rd2:sext_ext;

alu alu_u (
    .A(rf_rd1),
    .B(alu_b),
    .op(alu_op),
    .C(alu_c),
    .comp(alu_comp)
);

endmodule