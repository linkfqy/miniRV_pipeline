module alu (
    input [31:0] A,
    input [31:0] B,
    input [3:0] op,
    output reg [31:0] C,
    output [1:0] comp
);

assign comp = (A==B)?2'b10:
              (($signed(A)<$signed(B))?2'b01:2'b00);

always @(*) begin
    case (op)
        4'b0000: C=B;
        4'b0001: C=A+B;
        4'b0010: C=A-B;
        4'b0011: C=A&B;
        4'b0100: C=A|B;
        4'b0101: C=A^B;
        4'b0110: C=A<<B[4:0];
        4'b0111: C=A>>B[4:0];
        4'b1000: C=($signed(A))>>>B[4:0];
        default: C=32'b0;  // 未定义操作
    endcase
end

endmodule