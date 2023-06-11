module ctrl # (
    R     = 7'b0110011,
    I     = 7'b0010011,  // "xxi" type instruction
    L     = 7'b0000011,  // load
    JALR  = 7'b1100111,
    S     = 7'b0100011,  // store
    B     = 7'b1100011,  // branch
    LUI   = 7'b0110111,
    J     = 7'b1101111   // jal
)
(
    input [10:0] inst,
    input  [1:0] eqlt,
    output reg [1:0] npc_op,
    output reg [2:0] sext_op,
    output reg       rf_we,
    output           alub_sel,
    output reg [3:0] alu_op,
    output           dram_we,
    output reg [1:0] wd_sel
);

wire [6:0] opcode = inst[6:0];
wire [2:0] f3 = inst[9:7];
wire f7 = inst[10];  // funct7的左数第二位
wire eq = eqlt[1];
wire lt = eqlt[0];

reg [1:0] npc_op_B;  // 分支指令的npcop
always @(*) begin
    case (f3)
        3'b000: npc_op_B=(eq)?2'b01:2'b00;  // beq
        3'b001: npc_op_B=(eq)?2'b00:2'b01;  // bne
        3'b100: npc_op_B=(lt)?2'b01:2'b00;  // blt
        3'b101: npc_op_B=(lt)?2'b00:2'b01;  // bge
        default: npc_op_B=2'b11;  // 未定义指令
    endcase
end

always @(*) begin  // npc_op控制
    case (opcode)
        R,I,L,S,LUI: npc_op = 2'b00;
        J:           npc_op = 2'b01;
        JALR:        npc_op = 2'b10;
        B:           npc_op = npc_op_B;
        default: npc_op=2'b11;  // 未定义指令
    endcase
end

always @(*) begin  // sext_op控制
    case (opcode)
        I,L,JALR: sext_op = 3'b001;
        S:        sext_op = 3'b010;
        B:        sext_op = 3'b011;
        LUI:      sext_op = 3'b100;
        J:        sext_op = 3'b101;
        default:  sext_op = 3'b111;  // R型或未定义指令
    endcase
end

always @(*) begin
    case (opcode)
        S,B:              rf_we = 0;
        R,I,L,J,JALR,LUI: rf_we = 1;
        default:          rf_we = 0;
    endcase
end

assign alub_sel = (opcode==R || opcode==B)?0:1;

always @(*) begin
    casez (inst)
        {4'b0000,R},{4'bz000,I}:                alu_op = 4'b0001;  // add addi
        {4'b1000,R}:                            alu_op = 4'b0010;  // sub
        {4'b0111,R},{4'bz111,I}:                alu_op = 4'b0011;  // and andi
        {4'b0110,R},{4'bz110,I}:                alu_op = 4'b0100;  // or ori
        {4'b0100,R},{4'bz100,I}:                alu_op = 4'b0101;  // xor xori
        {4'b0001,R},{4'b0001,I}:                alu_op = 4'b0110;  // sll
        {4'b0101,R},{4'b0101,I}:                alu_op = 4'b0111;  // srl
        {4'b1101,R},{4'b1101,I}:                alu_op = 4'b1000;  // sra
        {4'bz010,L},{4'bz000,JALR},{4'bz010,S}: alu_op = 4'b0001;
        {4'bzzzz,LUI}:                          alu_op = 4'b0000;
        default:                                alu_op = 4'b0000;  // B/J型或未定义指令
    endcase
end

assign dram_we = (opcode==S)?1:0;

always @(*) begin
    case (opcode)
        L:       wd_sel = 2'b10;
        JALR,J:  wd_sel = 2'b00;
        default: wd_sel = 2'b01;  // R/I/S/B/LUI型或未定义指令
    endcase
end

endmodule