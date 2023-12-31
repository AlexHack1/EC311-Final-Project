// Note Generator module with parameters. Many of the values are parameterized so you should be
// able to change them to make the note generator more flexible. Only the pwm_resolution does not work as that resolution is hard coded in the PWM module.

`timescale 1ns / 1ps

module note_generator #(
    parameter integer NOTE_COUNT = 12,
    parameter integer PWM_RESOLUTION = 8,     // PWM resolution in bits
    parameter integer OCTAVE_MAX = 7,         // Maximum octave
    parameter integer CLK_FREQUENCY = 100000, // Clock frequency in Hz - 100kHz default
    parameter integer SINE_LUT_SIZE = 256     // Size of the sine LUT (also triangle)
)(
    input wire clk,
    input wire rst,
    input wire [3:0] note,            // Note input (0-11 for C-B)

    input wire [3:0] duty_cycle_type, // 00 is 50% 01 is sine, 10 is triangle
    input [7:0] octave_in,
    input octave_flag,                // 1 is up, 0 is down

    output reg pwm_out,               // PWM output - can be tied directly to a speaker
    output wire pwm_led,              // for testing and debug
    output reg [27:0] current_frequency // Output current frequency
);

    assign pwm_led = pwm_out;         // for testing and debug

    //reg [PWM_RESOLUTION-1:0] counter = 0; // Idealy we would parameterize the counter but we had overflow issues so we settled for a 32 bit reg
    reg [31:0] counter = 0;
    reg [31:0] frequency; // Frequency for the note (in Hz * 100)
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


    // Unused since we have a new indexer at the bottom of the module
    reg [31:0] sine_wave_counter = 0; // counter for controlling sine wave speed
    // Sine Wave Generator with controlled speed 
    /*
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sine_index <= 0;
            sine_wave_counter <= 0;
        end else begin
            sine_wave_counter <= sine_wave_counter + 1;
            if (sine_wave_counter >= 10 )  // modify 100 to change speed of sine wave
            begin 
                sine_wave_counter <= 0;
                sine_index <= (sine_index + 1) % 256; // 256 is the size of the sine LUT
            end
        end
    end
    */
    
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
        if (rst) begin // Reset to middle C
                frequency = base_freqs[note];
        end
        case(octave_flag)
            1:
                case(octave_in)
                    0: frequency = base_freqs[note]/16;
                    5: frequency = base_freqs[note]/8;
                    10: frequency = base_freqs[note]/8;
                    15: frequency = base_freqs[note]/4;
                    20: frequency = base_freqs[note]/4;
                    25: frequency = base_freqs[note]/2;
                    30: frequency = base_freqs[note]/2;
                    35: frequency = base_freqs[note];
                    40: frequency = base_freqs[note];
                    45: frequency = base_freqs[note]*2;
                    50: frequency = base_freqs[note]*2;
                    55: frequency = base_freqs[note]*4;
                    60: frequency = base_freqs[note]*4;
                    65: frequency = base_freqs[note] * 8;
                    70: frequency = base_freqs[note]*8;
                    75: frequency = base_freqs[note] * 8;
                endcase
            0:
                 case(octave_in)
                    0: frequency = base_freqs[note]/16;
                    5: frequency = base_freqs[note]/16;
                    10: frequency = base_freqs[note]/8;
                    15: frequency = base_freqs[note]/8;
                    20: frequency = base_freqs[note]/4;
                    25: frequency = base_freqs[note]/4;
                    30: frequency = base_freqs[note]/2;
                    35: frequency = base_freqs[note]/2;
                    40: frequency = base_freqs[note];
                    45: frequency = base_freqs[note];
                    50: frequency = base_freqs[note]*2;
                    55: frequency = base_freqs[note]*2;
                    60: frequency = base_freqs[note]*4;
                    65: frequency = base_freqs[note]*4;
                    70: frequency = base_freqs[note]*8;
                endcase
            
            default:;
        endcase
        current_frequency = frequency; // for display on the 7segment
    end

    
    
    
    // new clock divider - unused
    reg divided_clk = 0;
    reg [31:0] clk_divider_counter = 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_divider_counter <= 0;
            divided_clk <= 0;
        end else begin
            // Increment the counter each clock cycle
            clk_divider_counter <= clk_divider_counter + 1;
    
            // Change the divided clock value when counter reaches 5000
            if (clk_divider_counter >= 5000) begin
                clk_divider_counter <= 0;
                divided_clk <= ~divided_clk;
            end
        end
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
                        pwm_out <= (counter < ((CLK_FREQUENCY) / (frequency) * sine_value)) ? 1'b1 : 1'b0;
                    end
                2'b10: begin
                    //triangle duty cycle
                        pwm_out <= (counter < ((CLK_FREQUENCY) / (frequency) * triangle_value)) ? 1'b1 : 1'b0;
                    end
                default: begin
                    // Default to 50% Duty Cycle
                    pwm_out <= (counter < ((CLK_FREQUENCY*100) / (frequency) / 2)) ? 1'b1 : 1'b0;
                end 
           endcase 
        end
    end


    reg [31:0] sine_increment;       // Increment value for sine_index
    reg [31:0] sine_accumulator = 0; // Accumulator for fractional increments (needed to ensure frequency is accurate)

    // sbasic ine wave increment
    always @(posedge clk) begin
        if (rst) begin
            sine_increment <= 0;
            sine_accumulator <= 0;
        end else begin
            sine_increment <= (frequency * SINE_LUT_SIZE) / CLK_FREQUENCY;
        end
    end


    // PWM sine indexer adjuster
    // This indexer does not work with the triangle wave for some reason
    // We do not know how to fix triangle because this relies on the low pass filtering on the board to output proper triangle sound
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sine_index <= 0;
            sine_accumulator <= 0;
        end else begin
            sine_accumulator <= sine_accumulator + sine_increment;
            if (sine_accumulator >= CLK_FREQUENCY) begin
                sine_accumulator <= sine_accumulator - CLK_FREQUENCY;
                sine_index <= (sine_index + 1) % SINE_LUT_SIZE;
            end
        end
    end

endmodule