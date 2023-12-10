`timescale 1ns / 1ps

module display_mode(
    input wire clk,          // 500Hz
    input wire [2:0] mode,   // Mode - 8 modes
    
    // inputs we swtich between
    input wire [3:0] note,
    input wire [2:0] octave,
    input wire [31:0] frequency,
    input wire [3:0] pwm_type,
    
    output reg [5:0] val_TBD0, // disp0 (left digit)
    output reg [5:0] val_TBD1, // disp1
    output reg [5:0] val_TBD2, // disp2
    output reg [5:0] val_TBD3, // disp3
    output reg [5:0] val_TBD4, // disp4
    output reg [5:0] val_TBD5, // disp5
    output reg [5:0] val_TBD6, // disp6
    output reg [5:0] val_TBD7  // disp7 (right digit)
);
    parameter NOTHING = 5'b10000;
    parameter SYM_DASH= 5'b10010;
    parameter SYM_UNDERSCORE = 5'b10100;
    parameter SYM_TOP = 5'b10101;

    reg [4:0] note_dig1; // note digit 1 
    reg [4:0] note_dig2; // note digit 2

    reg [7:0] animation_counter = 0; // Counter for pwm animation
    
    reg [3:0] ten_thousands;
    reg [3:0] thousands;
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;
    reg [3:0] tenths;
    reg [3:0] hundredths;

    always @(posedge clk) begin
        case (mode)
            3'b000: begin // Mode 0: Display note on the first 2 digits and octave on the third digit

                // case statement that converts note index to its proper hex value for display
                case(note)
                    4'b0000: begin // C_
                        note_dig1 <= 5'hC; // C
                        note_dig2 <= NOTHING;
                    end
                    4'b0001: begin // C#
                        note_dig1 <= 5'hC; // C
                        note_dig2 <= 5'h5; // # (5)
                    end
                    4'b0010: begin // D_
                        note_dig1 <= 5'hD; // D
                        note_dig2 <= NOTHING;
                    end
                    4'b0011: begin // D#
                        note_dig1 <= 5'hD; // D
                        note_dig2 <= 5'h5; // # (5)
                    end
                    4'b0100: begin // E_
                        note_dig1 <= 5'hE; // E
                        note_dig2 <= NOTHING;
                    end
                    4'b0101: begin // F_
                        note_dig1 <= 5'hF; // F
                        note_dig2 <= NOTHING;
                    end
                    4'b0110: begin // F#
                        note_dig1 <= 5'hF; // F
                        note_dig2 <= 5'h5; // # (5)
                    end
                    4'b0111: begin // G_
                        note_dig1 <= 5'b10011; // G
                        note_dig2 <= NOTHING;
                    end
                    4'b1000: begin // G#
                        note_dig1 <= 5'b10011; // G
                        note_dig2 <= 5'h5; // # (5)
                    end
                    4'b1001: begin // A_
                        note_dig1 <= 5'hA; // A
                        note_dig2 <= NOTHING;
                    end
                    4'b1010: begin // A#
                        note_dig1 <= 5'hA; // A
                        note_dig2 <= 5'h5; // # (5)
                    end
                    4'b1011: begin // B_
                        note_dig1 <= 5'hB; // B
                        note_dig2 <= NOTHING;
                    end
                    default: begin // __
                        note_dig1 <= NOTHING;
                        note_dig2 <= NOTHING;
                    end
                endcase
                
                // assign to display note value and octave
                val_TBD0 <= note_dig1;
                val_TBD1 <= note_dig2;
                val_TBD2 <= 5'b10001; // degree symbol (meaning octave)
                val_TBD3 <= {1'b0, octave}; // octave number



                // Increment animation counter for pwm type
                if (pwm_type == 2'b01) begin // sine wave
                    animation_counter <= (animation_counter + 1) % 4; // 4 steps for sine wave
                end else if (pwm_type == 2'b00) begin // square wave 
                    animation_counter <= (animation_counter + 1) % 2; // 2 steps for square wave
                end
                
                // Choose animation based on pwm_type
                case (pwm_type)
                    00: begin // square wave -_-_
                        case (animation_counter)
                            0: begin
                                val_TBD7 = SYM_UNDERSCORE;
                                val_TBD6 = SYM_DASH;
                                val_TBD5 = SYM_UNDERSCORE;
                                val_TBD4 = SYM_DASH;
                            end
                            1: begin
                                val_TBD7 = SYM_DASH;
                                val_TBD6 = SYM_UNDERSCORE;
                                val_TBD5 = SYM_DASH;
                                val_TBD4 = SYM_UNDERSCORE;
                            end
                        endcase
                    end
                    01: begin // sine wave _-~-_-~-_
                        case (animation_counter)
                            0: begin
                                val_TBD7 = SYM_UNDERSCORE;
                                val_TBD6 = SYM_DASH;
                                val_TBD5 = SYM_TOP;
                                val_TBD4 = SYM_DASH;
                            end
                            1: begin
                                val_TBD7 = SYM_DASH;
                                val_TBD6 = SYM_TOP;
                                val_TBD5 = SYM_DASH;
                                val_TBD4 = SYM_UNDERSCORE;
                            end
                            2: begin
                                val_TBD7 = SYM_TOP;
                                val_TBD6 = SYM_DASH;
                                val_TBD5 = SYM_UNDERSCORE;
                                val_TBD4 = SYM_DASH;
                            end
                            3: begin
                                val_TBD7 = SYM_DASH;
                                val_TBD6 = SYM_UNDERSCORE;
                                val_TBD5 = SYM_DASH;
                                val_TBD4 = SYM_TOP;
                            end
                        endcase
                    end
                endcase



                // blanks
                //val_TBD4 <= NOTHING;
                //val_TBD5 <= NOTHING;
                
                // display wave mode (square or sine or whatever)
                //val_TBD6 <= {1'b0, pwm_type[3:2]}; // Display the upper 2 bits of pwm_type
                //val_TBD7 <= {1'b0, pwm_type[1:0]}; // Display the lower 2 bits of pwm_type
            end
            
            
            3'b001: begin // Mode 1: Display frequency

                // Division and modulo operations to extract each digit for decimal display
                ten_thousands = (frequency / 10000) % 10;
                thousands = (frequency / 1000) % 10;
                hundreds = (frequency / 100) % 10;
                tens = (frequency / 10) % 10;
                ones = frequency % 10;
                tenths = (frequency / 100) % 10;
                hundredths = (frequency / 1000) % 10;

                // Mapping each digit to the display values
                val_TBD0 <= 6'hF;
                val_TBD1 <= {1'b0, 1'b0, ten_thousands};
                val_TBD2 <= {1'b0, 1'b0, thousands};
                val_TBD3 <= {1'b0, 1'b0, hundreds};
                val_TBD4 <= {1'b0, 1'b0, tens};
                val_TBD5 <= {1'b1, 1'b0, ones}; // 1'b1 is decimal point
                val_TBD6 <= {1'b0, 1'b0, tenths};
                val_TBD7 <= {1'b0, 1'b0, hundredths};

            end
            
            
            default: begin
                // disp nothing in default case
                val_TBD0 <= NOTHING;
                val_TBD1 <= NOTHING;
                val_TBD2 <= NOTHING;
                val_TBD3 <= NOTHING;
                val_TBD4 <= NOTHING;
                val_TBD5 <= NOTHING;
                val_TBD6 <= NOTHING;
                val_TBD7 <= NOTHING;
            end
        endcase
    end

endmodule
