`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:28:31 11/27/2017 
// Design Name: 
// Module Name:    Cloc_divider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module faster_clock_divider(
    input in_clk, 
    output reg out_clk);
	
	reg[32:0] count;

	initial begin
		// initialize everything to zero
		count = 0;
		out_clk = 0;
	end
	
	always @(negedge in_clk)
	begin
	   count <= count + 1;
	   if (count >= 100000) begin
	       
	       out_clk <= ~out_clk;
	       count <= 0;    
		// increment count by one
		// if count equals to some big number (that you need to calculate),
		//   then flip the output clock,
		//   and reset count to zero.
	   end
    end

endmodule