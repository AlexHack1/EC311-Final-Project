`timescale 1ns / 1ps

module top(
    input CLK100MHZ, // System clock (100MHz)
    input rst,
    output wire AUD_PWM // PWM output direct to speaker
);

    // Parameters for the note generator
    parameter integer NOTE_COUNT = 12;
    parameter integer PWM_RESOLUTION = 8;
    parameter integer OCTAVE_MAX = 7;
    parameter integer CLK_FREQUENCY = 1000000;

    // Internal signals
    reg [3:0] current_note = 0; // Current note (0-11 for C-B)
    reg [1:0] octave_change = 2'b00; // No octave change by default
    reg [23:0] note_change_counter = 0; // Counter to change notes periodically

    // note generator module
    note_generator #(
        .NOTE_COUNT(NOTE_COUNT),
        .PWM_RESOLUTION(PWM_RESOLUTION),
        .OCTAVE_MAX(OCTAVE_MAX),
        .CLK_FREQUENCY(CLK_FREQUENCY)
    ) note_gen (
        .clk(clk),
        .rst(rst),
        .note(current_note),
        .octave_change(octave_change),
        .pwm_out(AUD_PWM)
    );

    // Note change logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_note <= 0;
            note_change_counter <= 0;
        end else begin
            // Increment the note change counter
            note_change_counter <= note_change_counter + 1'b1;

            // Change the note every predefined interval
            if (note_change_counter >= 24'd1000000) begin // controls how long each note is played
                current_note <= (current_note + 1) % NOTE_COUNT; // increment note
                note_change_counter <= 0;
            end
        end
    end

endmodule
