`timescale 1ns / 1ps

module top(
    input CLK100MHZ,       // FPGA board clock (assumed to be much higher than 1kHz)
    input rst_button,      // Reset button
    input next_note_button,// Button to change to the next note
    input octave_up, //octave up button 
    input octave_down, //octave down button
    input mode0,
    input mode1,
    input mode2,
    
    // outputs to board
    output [7:0] cathode_seg,   // 7-segment cathode outputs
    output [7:0] anode_seg,      // 7-segment anode outputs (8 bits since we include decimal point here)
    output wire AUD_PWM,         // Output to a speaker or an 
    output wire led0        // for debug
);

    reg [3:0] note = 0;          // Note storage
    wire [2:0] octave_number; //octave storage
    //reg [1:0] octave_change = 0; // Octave change variable
    wire clk_100kHz;
    wire clk_500Hz;
    wire [27:0] current_freq;
    
    // for note generator
    clk_div my_clk_100kHz(
        .clk_in(CLK100MHZ),
        .clk_out(clk_100kHz)
    );
    
    // slow clock (500hz) for display   
    sev_clock my_sev_clk (
        .clock_in(CLK100MHZ),
        .clock_out(clk_500Hz)
    );

    // Instantiate note_generator with 100kHz clock
    note_generator #(
        .NOTE_COUNT(12),
        .PWM_RESOLUTION(8),
        .OCTAVE_MAX(7),
        .CLK_FREQUENCY(100000), // 100kHz clock
        .DUTY_CYCLE(2)         // Duty cycle (for square wave = 2)
    ) my_note_generator (
        .clk(clk_100kHz),
        .rst(rst_button),
        .note(note),
        .octave_up(octave_up),
        .octave_down(octave_down),
        .pwm_out(AUD_PWM),
        .pwm_led(led0),
        .octave_number(octave_number),
        .current_frequency(current_freq)
    );
    
    // display mode gets tied to 7seg disp
    reg [2:0] disp_mode;
    always @(mode0, mode1, mode2) begin
        disp_mode = {mode2, mode1, mode0};
    end
    wire [4:0] disp0, disp1, disp2, disp3, disp4, disp5, disp6, disp7;
    display_mode my_display_mode (
        .clk(clk_500Hz),
        .mode(disp_mode),
        .note(note),
        .octave(octave_number),
        .frequency(current_freq),
        .val_TBD0(disp0),
        .val_TBD1(disp1),
        .val_TBD2(disp2),
        .val_TBD3(disp3),
        .val_TBD4(disp4),
        .val_TBD5(disp5),
        .val_TBD6(disp6),
        .val_TBD7(disp7)
    );

    // basic note incrementer for debug
    always @(posedge clk_500Hz) begin
        if (rst_button) begin
            note <= 0;
        end else if (next_note_button) begin
            if (note < 11) begin
                note <= note + 1;
            end else begin
                note <= 0;
                // Handle octave change here if desired
            end
        end
    end
    
    // 7 segment display using 5 bit BCD 
    // each digit is in correct order left to right dont move them
    segment_disp sevendisp (
        .val_TBD5(disp0),
        .val_TBD4(disp1),
        .val_TBD3(disp2),
        .val_TBD2(disp3),
        .val_TBD1(disp4),
        .val_TBD0(disp5),
        .val_TBD7(disp6), 
        .val_TBD6(disp7),

        .clock_in(clk_500Hz),
        .reset_in(rst_button),
        .cathode_out(cathode_seg),
        .anode_out(anode_seg)
    );

    /*
    segment_disp sevendisp (
        .val_TBD5(5'b00000),
        .val_TBD4(5'b00000),
        .val_TBD3(5'b00000),
        .val_TBD2(5'b00000),
        .val_TBD1(5'b00000),
        .val_TBD0(5'b00000),
        .val_TBD7(octave_number), //deg symbol
        .val_TBD6(note), // c or f or nothing

        .clock_in(clk_500Hz),
        .reset_in(rst_button),
        .cathode_out(cathode_seg),
        .anode_out(anode_seg)
    );
    */

endmodule