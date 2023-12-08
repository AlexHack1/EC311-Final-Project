`timescale 1ns / 1ps

module display_mode(
    input wire clk,          // 500Hz
    input wire [2:0] mode,   // Mode - 8 modes
    
    // inputs we swtich between
    input wire [3:0] note,
    input wire [2:0] octave,
    input wire [31:0] frequency,
    
    output reg [4:0] val_TBD0, // disp0 (left digit)
    output reg [4:0] val_TBD1, // disp1
    output reg [4:0] val_TBD2, // disp2
    output reg [4:0] val_TBD3, // disp3
    output reg [4:0] val_TBD4, // disp4
    output reg [4:0] val_TBD5, // disp5
    output reg [4:0] val_TBD6, // disp6
    output reg [4:0] val_TBD7  // disp7 (right digit)
);
    parameter NOTHING = 5'b10000;

    reg [4:0] note_dig1; // note digit 1 
    reg [4:0] note_dig2; // note digit 2

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
                        note_dig1 <= 5'h10; // G
                        note_dig2 <= NOTHING;
                    end
                    4'b1000: begin // G#
                        note_dig1 <= 5'h10; // G
                        note_dig2 <= 5'h5; // # (5)
                    end
                    4'b1001: begin // A_
                        note_dig1 <= 5'h11; // A
                        note_dig2 <= NOTHING;
                    end
                    4'b1010: begin // A#
                        note_dig1 <= 5'h11; // A
                        note_dig2 <= 5'h5; // # (5)
                    end
                    4'b1011: begin // B_
                        note_dig1 <= 5'h12; // B
                        note_dig2 <= NOTHING;
                    end
                    default: begin // __
                        note_dig1 <= NOTHING;
                        note_dig2 <= NOTHING;
                    end
                endcase
                
                val_TBD0 <= note_dig1;
                val_TBD1 <= note_dig2;
                val_TBD2 <= 5'b10001; // degree symbol (meaning octave)
                val_TBD3 <= {1'b0, octave}; // octave number

                // everything else is blank
                val_TBD4 <= NOTHING;
                val_TBD5 <= NOTHING;
                val_TBD6 <= NOTHING;
                val_TBD7 <= NOTHING;
            end
            
            
            3'b001: begin // Mode 1: Display frequency
                val_TBD0 <= 5'hF;
                val_TBD1 <= frequency[27:24];
                val_TBD2 <= frequency[23:20];
                val_TBD3 <= frequency[19:16];
                val_TBD4 <= frequency[15:12];
                val_TBD5 <= frequency[11:8];
                val_TBD6 <= frequency[7:4];
                val_TBD7 <= frequency[3:0];
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
