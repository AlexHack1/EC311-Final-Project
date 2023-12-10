`timescale 1ns / 1ps

module note_generator #(
    parameter integer NOTE_COUNT = 12,
    parameter integer PWM_RESOLUTION = 8, // PWM resolution in bits
    parameter integer OCTAVE_MAX = 7, // Maximum octave (not used for now since we only shift by one octave)
    parameter integer CLK_FREQUENCY = 100000, // Clock frequency in Hz - 100kHz default
    //parameter integer DUTY_CYCLE = 2, //default duty cycle of 50% = 2 (meaning 2 is the divisor)
    parameter integer SINE_LUT_SIZE = 256 // Size of the sine LUT
)(
    input wire clk,
    input wire rst,
    input wire [3:0] note, // Note input (0-11 for C-B)

    input wire [3:0] duty_cycle_type, // 00 is 50% 01 is sine...
    input [2:0] octave_in,

    output reg pwm_out, // PWM output - can be tied directly to a speaker
    output wire pwm_led, //for testing
    output reg [31:0] current_frequency // Output current frequency
);

    assign pwm_led = pwm_out;

    //reg [PWM_RESOLUTION-1:0] counter = 0; // Counter for generating PWM signal
    reg [31:0] counter = 0;
    reg [31:0] frequency; // Frequency for the note
    reg [2:0] octave_reg = 3'd4; // Octave count (starting at middle C)
    reg [7:0] sine_index = 0;
    
    wire [5:0] sine_value;
    wire [5:0] triangle_value;
    
    //wave lut
    wave_lut wavelut (
        .sine_input(sine_index),
        .triangle_input(sine_index),
        .sine_output(sine_value),
        .triangle_output(triangle_value)
    );

    // add a counter to slow the sine_index counter
    
    reg [31:0] sine_wave_counter = 0; // New counter for controlling sine wave speed

    // Sine Wave Generator with controlled speed
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sine_index <= 0;
            sine_wave_counter <= 0;
        end else begin
            sine_wave_counter <= sine_wave_counter + 1;
            if (sine_wave_counter >= 100 )  // modify 100 to change speed of sine wave
            begin 
                sine_wave_counter <= 0;
                sine_index <= (sine_index + 1) % 256; // 256 is the size of the sine LUT
            end
        end
    end
    
    
    // Frequency LUT for base octave (4th octave, ie middle C)
    integer base_freqs [0:NOTE_COUNT-1];
    initial begin
        // 100X Frequencies for the 4th octave 
        base_freqs[0] = 26163; // C
        base_freqs[1] = 27718; // C#
        base_freqs[2] = 29366; // D
        base_freqs[3] = 31113; // D#
        base_freqs[4] = 32963; // E
        base_freqs[5] = 34923; // F
        base_freqs[6] = 36999; // F#
        base_freqs[7] = 39200; // G
        base_freqs[8] = 41530; // G#
        base_freqs[9] = 44000; // A
        base_freqs[10] = 46616; // A#
        base_freqs[11] = 49388; // B
        
        
        
    end

    // octave adjustment based on octave_in
    always @ (posedge clk) begin
        octave_reg <= octave_in;
        if (rst) begin // Reset to middle C
                frequency = base_freqs[note];
        end
        case(octave_reg)
            0: frequency = base_freqs[note]/16;
            1: frequency = base_freqs[note]/8;
            2: frequency = base_freqs[note]/4;
            3: frequency = base_freqs[note]/2;
            4: frequency = base_freqs[note];
            5: frequency = base_freqs[note]*2;
            6: frequency = base_freqs[note]*4;
            7: frequency = base_freqs[note]*8;
            default:;
        endcase
         current_frequency = frequency;
    end


    // PWM Output Block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            pwm_out <= 0;
        end else begin
            counter <= counter + 1'b1; // increment counter
    
            // Reset the counter when the full period is reached
            if (counter >= ((CLK_FREQUENCY*100) / (frequency))) begin
                counter <= 0;
            end
    
            // Set pwm_out high depending on duty cycle mode
            case (duty_cycle_type)
                2'b00: begin
                        // 50% Duty Cycle - square (replace 2 with divisor for duty cycle)
                        pwm_out <= (counter < ((CLK_FREQUENCY*100) / (frequency) / 2)) ? 1'b1 : 1'b0;
                    end
                2'b01: begin
                        // sine duty cycle
                        pwm_out <= (counter < ((CLK_FREQUENCY*100*100) / (frequency) * sine_value / 1)) ? 1'b1 : 1'b0;
                    end
                2'b10: begin
                    //triangle duty cycle
                        pwm_out <= (counter < ((CLK_FREQUENCY*100*100) / (frequency) / triangle_value / 1)) ? 1'b1 : 1'b0;
                    end
                default: begin
                    // Default to 50% Duty Cycle
                    pwm_out <= (counter < ((CLK_FREQUENCY*100) / (frequency) / 2)) ? 1'b1 : 1'b0;
                end 
           endcase 
        end
    end

endmodule