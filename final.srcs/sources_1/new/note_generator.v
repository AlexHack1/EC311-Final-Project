module note_generator #(
    parameter integer NOTE_COUNT = 12,
    parameter integer PWM_RESOLUTION = 8, // PWM resolution in bits
    parameter integer OCTAVE_MAX = 7, // Maximum octave (not used for now since we only shift by one octave)
    parameter integer CLK_FREQUENCY = 1000000 // Clock frequency in Hz - 1 MHz
)(
    input wire clk,
    input wire rst,
    input wire [3:0] note, // Note input (0-11 for C-B)
    input wire [1:0] octave_change, // Octave change input (00: no change, 01: decrement, 10: increment)
    output reg pwm_out // PWM output - can be tied directly to a speaker
);

    reg [PWM_RESOLUTION-1:0] counter = 0; // Counter for generating PWM signal
    reg [31:0] frequency; // Frequency for the note
    reg [2:0] octave_count = 3'd4; // Octave count (starting at middle C)

    // Frequency LUT for base octave (4th octave, i.e., middle C)
    integer base_freqs [0:NOTE_COUNT-1];

    // Initialize the frequency array
    initial begin
        // Frequencies for the 4th octave
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
            frequency = frequency * (2 ** 1); // Multiply by 2 for each octave up (shift left)
        end else if (octave_shift < 0) begin
            // For lower octaves, divide by 2 for each octave below the 4th
            frequency = frequency >> 1; // Divide by 2 for each octave down (shift right)
        end

        // If octave_shift is 0 then this block does nothing
    end

    // Octave Adjustment Block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            octave_count <= 3'd4; // Reset to middle C
        end else begin
            case (octave_change)
                2'b10: if (octave_count < OCTAVE_MAX) octave_count <= octave_count + 1; // Increment octave
                2'b01: if (octave_count > 0) octave_count <= octave_count - 1; // Decrement octave
                default: ; // No change
            endcase
        end
    end


    // PWM Output Block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            pwm_out <= 0;
        end else begin
            counter <= counter + 1'b1;

            // Adjust PWM frequency based on the calculated frequency
            if (counter >= (CLK_FREQUENCY / (2 * frequency))) begin
                counter <= 0;
            end

            pwm_out <= (counter < (CLK_FREQUENCY / (2 * frequency))) ? 1'b1 : 1'b0; // 50% Duty Cycle (square wave)
        end
    end

endmodule
