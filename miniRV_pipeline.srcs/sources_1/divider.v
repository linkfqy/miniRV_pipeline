module divider(
    input  wire clk_i,
    input  wire rst_n,
    output reg  clk_o
    );

    reg [31:0] cnt;
    wire cnt_end = (cnt==32'd20000);
    
    always @ (posedge clk_i or negedge rst_n) begin
        if (~rst_n)   cnt <= 0;
        else if (cnt_end) cnt <= 0;
        else cnt <= cnt + 1;
    end
    
    always @ (posedge clk_i or negedge rst_n) begin
        if(~rst_n)  clk_o <= 0;
        else if (cnt_end)  clk_o <= ~clk_o;
    end

endmodule