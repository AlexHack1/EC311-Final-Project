`timescale 1ns / 1ps

module segment_disp(
    
    //input using 7 inputs rather than array because array wont work
    input [5:0] val_TBD0, // display 0
    input [5:0] val_TBD1, // display 1
    input [5:0] val_TBD2, // display 2
    input [5:0] val_TBD3, // display 3
    input [5:0] val_TBD4, // display 4
    input [5:0] val_TBD5, // display 5
    input [5:0] val_TBD6, // display 6
    input [5:0] val_TBD7, // display 7
    input clock_in,
	input reset_in,
	//input [3:0] count_in,
	output reg [7:0] cathode_out, //7 segments
	output reg [7:0] anode_out //to be used later
    );
    
    
    reg [5:0] val_TBD[7:0]; //internal array of whatever we want to display
    reg [7:0] seg_map;
    reg [2:0] digit_counter;  //counts 0-7 for selecting digit        
    
    //   A
    // F   B
    //   G
    // E   C
    //   D    H
    // 7 SEGMENT MAPPING //GFEDCBA// 1 is off 0 is on // MSB (H) is the decimal point
    parameter ZERO =    7'b1000000;  // 0
    parameter ONE =     7'b1111001;  // 1
    parameter TWO =     7'b0100100;  // 2
    parameter THREE =   7'b0110000;  // 3
    parameter FOUR =    7'b0011001;  // 4
    parameter FIVE =    7'b0010010;  // 5
    parameter SIX =     7'b0000010;  // 6
    parameter SEVEN =   7'b1111000;  // 7
    parameter EIGHT =   7'b0000000;  // 8
    parameter NINE =    7'b0010000;  // 9
    parameter LET_A =   7'b0001000;  // A
    parameter LET_B =   7'b0000011;  // B
    parameter LET_C =   7'b1000110;  // C
    parameter LET_D =   7'b0100001;  // D
    parameter LET_E =   7'b0000110;  // E
    parameter LET_F =   7'b0001110;  // F
    parameter NOTHING = 7'b1111111;  // disp nothing 
    parameter SYM_DEG = 7'b0011100;  // [] degree symbol
    parameter SYM_DASH= 7'b0111111;  // - negative symbol 
    parameter LET_G =   7'b1000010;  // G
    parameter SYM_UNDERSCORE = 7'b1110111; // _ underscore symbol
    parameter SYM_TOP = 7'b1111110; // ~ top segment only
    parameter triangle_0 = 7'b0011101; // triangle left side
    parameter triangle_1 = 7'b0011011; // triangle right side
    always @(posedge clock_in) begin
        case(val_TBD[digit_counter][4:0])
            5'h0: seg_map = ZERO;       
            5'h1: seg_map = ONE;       
            5'h2: seg_map = TWO;
            5'h3: seg_map = THREE;
            5'h4: seg_map = FOUR;
            5'h5: seg_map = FIVE;
            5'h6: seg_map = SIX;
            5'h7: seg_map = SEVEN;
            5'h8: seg_map = EIGHT;
            5'h9: seg_map = NINE;
            5'hA: seg_map = LET_A;
            5'hB: seg_map = LET_B;
            5'hC: seg_map = LET_C;
            5'hD: seg_map = LET_D;
            5'hE: seg_map = LET_E;
            5'hF: seg_map = LET_F;
            5'h10: seg_map = NOTHING; 
            5'b10001: seg_map = SYM_DEG;
            5'b10010: seg_map = SYM_DASH;
            5'b10011: seg_map = LET_G;
            5'b10100: seg_map = SYM_UNDERSCORE;
            5'b10101: seg_map = SYM_TOP;
            default : seg_map = 8'b11111111;  //turns all off
        endcase

        // assign the bit 8 (H) to the decimal point
        if (val_TBD[digit_counter][5] == 1'b0) begin
            seg_map[7] <= 1'b1; // Clear the decimal point for this digit
        end else begin
            seg_map[7] <= 1'b0; // Show the decimal point for this digit
        end
        
        //we assign the inputs to an internal array which is much easier to iterate thru
        val_TBD[0] = val_TBD0;
        val_TBD[1] = val_TBD1;
        val_TBD[2] = val_TBD2;
        val_TBD[3] = val_TBD3;
        val_TBD[4] = val_TBD4;
        val_TBD[5] = val_TBD5;
        val_TBD[6] = val_TBD6;
        val_TBD[7] = val_TBD7;
    end
    
    // sets anode out //
   always @(digit_counter) begin
    case(digit_counter)
        3'b000: anode_out = 8'b11111110;
        3'b001: anode_out = 8'b11111101;
        3'b010: anode_out = 8'b11111011;
        3'b011: anode_out = 8'b11110111;
        3'b100: anode_out = 8'b11101111;
        3'b101: anode_out = 8'b11011111;
        3'b110: anode_out = 8'b10111111;
        3'b111: anode_out = 8'b01111111;
        default: anode_out = 8'b11111111; //disp no digits
    endcase
    end
    
            
            
    initial begin
	    digit_counter = 3'b000;
	    cathode_out = 8'b11111111;
	end
            
    //digit counter incrementer and reset 
    always @(posedge clock_in or posedge reset_in) begin 
        if (reset_in) begin
            digit_counter <= 3'b000;
        end else begin
            digit_counter <= digit_counter + 1;
            //$display("Clock edge, digit_counter set to: %b", digit_counter);
            
            cathode_out <= seg_map; //sets cathode_out to the seg_map
            //cathode_out[7] <= 1'b1; // Clears the MSB since in most cases we dont want a decimal to disp
        end
    end
    

    
endmodule
