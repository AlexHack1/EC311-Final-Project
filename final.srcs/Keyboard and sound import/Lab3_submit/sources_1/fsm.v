`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2023 08:43:13 AM
// Design Name: 
// Module Name: fsm
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


module fsm(
        input clock,
        input [15:0] sixteen_bit_number,
        output [6:0] cathode,
        output reg [7:0] anode
    );
    
    reg [3:0] four_bit_number;
    decoder decode(four_bit_number,cathode);
    // instantiate decoder that decodes the four bit number into the cathode
    reg [1:0] state; // stores state of FSM
    
    initial begin
		state = 0;
		four_bit_number = 0;
		anode = 8'b11111111;
	end
    
    always @(posedge clock)
	begin
	   state <= state +1;
	   case(state)
	       0:begin four_bit_number = sixteen_bit_number[3:0]; 
	       anode = 8'b11111110; end
	       1:begin four_bit_number = sixteen_bit_number[7:4]; 
	       anode = 8'b11111101; end
	       2:begin four_bit_number = sixteen_bit_number[11:8]; 
	       anode = 8'b11111011; end
	       3:begin four_bit_number = sixteen_bit_number[15:12]; 
	       anode = 8'b11110111; end
	   
	   endcase
		// increment state
		// set anode (which display do you want to set?)
		//   hint: if state == 0, then set only the LSB of anode to zero,
		//         if state == 1, then set only the second to LSB to zero.
		// set the four bit number to be the approprate slice of the 16-bit number
	end
    
endmodule
