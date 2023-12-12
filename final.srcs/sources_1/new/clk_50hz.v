// Used in recording module to show down signifcantly to reduce the size of data 
// and allow for longer recording

`timescale 1ns / 1ps

// basic divider divodes by 10
module clock_divider_50hz(
    input clk_500hz,    // Input clock at 500Hz
    output reg clk_50hz // Output clock at 50Hz
);

    reg [3:0] count = 0; // 4-bit counter to count up to 10

    always @(posedge clk_500hz) begin
        count <= count + 1;
        if (count >= 9) begin
            count <= 0;
            clk_50hz <= ~clk_50hz; // Toggle the output clock
        end
    end

endmodule
