`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2023 04:11:20 PM
// Design Name: 
// Module Name: sine_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sine_tb(

    );
endmodule
module tb;

    // Inputs
    reg Clk;

    // Outputs
    wire [7:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    sine_wave_gen uut (
        .Clk(Clk), 
        .data_out(data_out)
    );

    //Generate a clock with 10 ns clock period.
    initial Clk = 0;
    always #5 Clk = ~Clk;
    
endmodule
