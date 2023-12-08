`timescale 1ns / 1ps

module note_generator #(
    parameter integer NOTE_COUNT = 12,
    parameter integer PWM_RESOLUTION = 8, // PWM resolution in bits
    parameter integer OCTAVE_MAX = 7, // Maximum octave (not used for now since we only shift by one octave)
    parameter integer CLK_FREQUENCY = 100000, // Clock frequency in Hz - 100kHz default
    parameter integer DUTY_CYCLE = 2 //default duty cycle of 50% = 2 (meaning 2 is the divisor)
)(
    input wire clk,
    input wire rst,
    input wire [3:0] note, // Note input (0-11 for C-B)
    input wire octave_up, //octave up button
    input wire octave_down, //octave donwn button
    output reg pwm_out, // PWM output - can be tied directly to a speaker
    output wire pwm_led, //for testing
    output [2:0] octave_number //passing to top to sevenseg display
);

    assign pwm_led = pwm_out;

    //reg [PWM_RESOLUTION-1:0] counter = 0; // Counter for generating PWM signal
    reg [31:0] counter = 0;
    reg [31:0] frequency; // Frequency for the note
    reg [2:0] octave_count = 3'd4; // Octave count (starting at middle C)
    assign octave_number = octave_count;
    
    
    

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

    // PWM Frequency Calculation
    integer octave_shift;
    always @* begin
        // Start with the base frequency for the current note
        frequency = base_freqs[note];
        
        // Calculate the octave shift from the 4th octave
        octave_shift = octave_count - 4;
        
        // Adjust frequency based on the octave
        if (octave_shift > 0) begin
            // For higher octaves, multiply by 2 for each octave above the 4th
            frequency = frequency * (2 * 1); // Multiply by 2 for each octave up (shift left)
        end else if (octave_shift < 0) begin
            // For lower octaves, divide by 2 for each octave below the 4th
            frequency = frequency / (2 * 1); // Divide by 2 for each octave down (shift right)
        end 

        // If octave_shift is 0 then this block does nothing
    end

    // Octave Adjustment Block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            octave_count <= 3'd4; // Reset to middle C
        end else begin
            if (octave_up) octave_count <= octave_count + 1; // Increment octave
            if (octave_down) octave_count <= octave_count - 1; // Decrement octave
            if (octave_count > OCTAVE_MAX)
                octave_count <= 3'd4; //reset middle C
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
    
            // Set pwm_out high for duty cycle 
            pwm_out <= (counter < ((CLK_FREQUENCY*100) / (frequency) / DUTY_CYCLE)) ? 1'b1 : 1'b0;
        end
    end

endmodule