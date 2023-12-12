`timescale 1ns / 1ps

module note_generator_tb;

    parameter integer NOTE_COUNT = 12;
    parameter integer PWM_RESOLUTION = 8;
    parameter integer OCTAVE_MAX = 7;
    parameter integer CLK_FREQUENCY = 100000; // 100 kHz for example
    parameter integer NOTE_TIME = 8000000; // time to play each note (in ns so big number)
    parameter integer DUTY_CYCLE = 3;

    // Inputs
    reg clk;
    reg rst;
    reg [3:0] note;
    reg [1:0] octave_change;

    // Outputs
    wire pwm_out;

    note_generator #(
        .NOTE_COUNT(NOTE_COUNT),
        .PWM_RESOLUTION(PWM_RESOLUTION),
        .OCTAVE_MAX(OCTAVE_MAX),
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .DUTY_CYCLE(DUTY_CYCLE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .note(note),
        .octave_change(octave_change),
        .pwm_out(pwm_out)
    );

    // Clock 
    always #(5000) clk = ~clk; // 100 kHz clock
    // always #5 clk = ~clk; // 100 MHz clock
    
    
    // for checking in console that the note generator is working
    reg [31:0] last_rising_edge_time;
    reg [31:0] last_falling_edge_time;
    reg [31:0] high_time;
    reg [31:0] low_time;

    // for console output
    always @(posedge pwm_out or negedge pwm_out) begin
        if(pwm_out) begin
            // Rising edge detected
            last_rising_edge_time = $time; // Capture the current simulation time
            low_time = last_rising_edge_time - last_falling_edge_time; // Calculate the low time duration
            if (last_falling_edge_time > 0) begin // Avoid printing at the initial rising edge
                $display("Low time: %0d ns", low_time);
            end
        end else begin
            // Falling edge detected
            last_falling_edge_time = $time; // Capture the current simulation time
            high_time = last_falling_edge_time - last_rising_edge_time; // Calculate the high time duration
            $display("High time: %0d ns", high_time);
        end
    end


    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        note = 0;
        octave_change = 2'b00;

        // reset for a bit
        #100;
        rst = 0;

        #NOTE_TIME; note = 0; octave_change = 2'b00; // Note C, middle octave 
        #NOTE_TIME; note = 1; octave_change = 2'b00; // Note C#, middle octave
        #NOTE_TIME; note = 2; octave_change = 2'b10; // Note D, octave up
        #NOTE_TIME; note = 3; octave_change = 2'b01; // Note D#, octave down
        #NOTE_TIME; note = 4; octave_change = 2'b00; // Note E, middle octave

        #500;
        $finish;
    end

endmodule