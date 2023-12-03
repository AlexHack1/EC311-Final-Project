`timescale 1ns / 1ps

module clk_divider(
    input clk,
    input [31:0] max,
    output reg sclk
    );

reg [31:0] count;
initial begin
    sclk = 0;
    count = 0;
end

always @(posedge clk) begin
    if (count < max) begin
        sclk <= sclk;
        count <= count + 1;
    end else if (count == max) begin
        sclk <= ~sclk;
        count <= 0;
    end
end

endmodule
