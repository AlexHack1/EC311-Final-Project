`timescale 1ns / 1ps

module note_generator_tb;

    // Parameters
    parameter integer NOTE_COUNT = 12;
    parameter integer PWM_RESOLUTION = 8;
    parameter integer OCTAVE_MAX = 7;
    parameter integer CLK_FREQUENCY = 100000; // 100 kHz for example
    parameter integer NOTE_TIME = 20000000; // time to play each note

    // Inputs
    reg clk;
    reg rst;
    reg [3:0] note;
    reg [1:0] octave_change;

    // Outputs
    wire pwm_out;

    // Instantiate the Unit Under Test (UUT)
    note_generator #(
        .NOTE_COUNT(NOTE_COUNT),
        .PWM_RESOLUTION(PWM_RESOLUTION),
        .OCTAVE_MAX(OCTAVE_MAX),
        .CLK_FREQUENCY(CLK_FREQUENCY)
    ) uut (
        .clk(clk),
        .rst(rst),
        .note(note),
        .octave_change(octave_change),
        .pwm_out(pwm_out)
    );

    // Clock generation
    always #(5000) clk = ~clk; // 100 kHz clock
    // always #5 clk = ~clk; // 100 MHz clock


    // Test sequence
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        note = 0;
        octave_change = 2'b00;

        // Reset the system
        #100;
        rst = 0;

        // Test different notes and octaves
        #NOTE_TIME; note = 0; octave_change = 2'b00; // Note C, middle octave 
        #NOTE_TIME; note = 1; octave_change = 2'b00; // Note C#, middle octave
        #NOTE_TIME; note = 2; octave_change = 2'b10; // Note D, octave up
        #NOTE_TIME; note = 3; octave_change = 2'b01; // Note D#, octave down
        #NOTE_TIME; note = 4; octave_change = 2'b00; // Note E, middle octave
        // Continue testing other notes and octave changes...

        // End of test
        #500;
        $finish;
    end

endmodule