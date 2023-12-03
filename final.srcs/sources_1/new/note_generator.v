module note_generator #(
    parameter integer NOTE_COUNT = 12, // Number of notes
    parameter integer PWM_RESOLUTION = 8, // 8-bit resolution for PWM
    parameter integer OCTAVE_MAX = 7 // Maximum octave count
)(
    input wire clk,
    input wire rst,
    input wire [3:0] note, // Note input (0-11 for C-B)
    input wire [1:0] octave_change, // Octave change input (00: no change, 01: decrement, 10: increment)
    output reg pwm_out // PWM output - can be tied directly to a speaker
);

    reg [PWM_RESOLUTION-1:0] counter; // Counter for generating PWM signal
    reg [PWM_RESOLUTION-1:0] duty_cycle; // Duty cycle for PWM
    reg [2:0] octave_count = 3'd4; // Octave count (starting at middle C)

    // Frequency LUT for base octave (4th octave, i.e., middle C)
    real note_freqs [0:NOTE_COUNT-1];

    initial begin
        // Frequencies for the 4th octave
        note_freqs[0] = 261.63; // C
        note_freqs[1] = 277.18; // C#
        note_freqs[2] = 293.66; // D
        note_freqs[3] = 311.13; // D#
        note_freqs[4] = 329.63; // E
        note_freqs[5] = 349.23; // F
        note_freqs[6] = 369.99; // F#
        note_freqs[7] = 392.00; // G
        note_freqs[8] = 415.30; // G#
        note_freqs[9] = 440.00; // A
        note_freqs[10] = 466.16; // A#
        note_freqs[11] = 493.88; // B
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
            duty_cycle <= (PWM_RESOLUTION * note_freqs[note]) / (2 ** octave_count); // Adjust duty cycle based on note and octave
            pwm_out <= (counter < duty_cycle) ? 1'b1 : 1'b0;
        end
    end

endmodule
