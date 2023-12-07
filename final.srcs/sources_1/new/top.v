module top(
    input wire CLK100MHZ,       // FPGA board clock (assumed to be much higher than 1kHz)
    input wire rst_button,      // Reset button
    input wire next_note_button,// Button to change to the next note
    output wire AUD_PWM         // Output to a speaker or an LED
);

    reg [3:0] note = 0;          // Note storage
    reg [1:0] octave_change = 0; // Octave change variable
    wire rst;                    // Internal reset signal
    wire clk_100kHz;

    clk_div my_clk_100kHz(
        .clk_in(CLK100MHZ),
        .clk_out(clk_100kHz)
    );

    // Instantiate note_generator with 100kHz clock
    note_generator #(
        .NOTE_COUNT(12),
        .PWM_RESOLUTION(8),
        .OCTAVE_MAX(7),
        .CLK_FREQUENCY(100000), // 100kHz clock
        .DUTY_CYCLE(2)         // Duty cycle (square wave)
    ) my_note_generator (
        .clk(clk_100kHz),
        .rst(rst),
        .note(note),
        .octave_change(octave_change),
        .pwm_out(AUD_PWM)
    );

    // Logic to handle note changes
    always @(posedge CLK100MHZ) begin
        if (rst) begin
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

    // Reset logic (inverted if button is active-low)
    assign rst = ~rst_button;

endmodule