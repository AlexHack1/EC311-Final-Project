module note_generator #(
   parameter integer NOTE_COUNT = 12, // Number of notes
   parameter integer PWM_RESOLUTION = 8 // 8-bit resolution for PWM
)(
   input wire clk,
   input wire rst,
   input wire [3:0] note, // Note input (0-11 for C-B)
   output reg pwm_out // PWM output - can be tied direct to contstraint
);

   reg [PWM_RESOLUTION-1:0] counter;   // Counter for generating PWM signal
   reg [PWM_RESOLUTION-1:0] duty_cycle; // Duty cycle for PWM

   // frequency LUT
   reg [PWM_RESOLUTION-1:0] note_freqs [0:NOTE_COUNT-1];

   initial begin
       note_freqs[0] = 261; // C
       note_freqs[1] = 277; // C#
       note_freqs[2] = 294; // D
       note_freqs[3] = 311; // D#
       note_freqs[4] = 330; // E
       note_freqs[5] = 349; // F
       note_freqs[6] = 370; // F#
       note_freqs[7] = 392; // G
       note_freqs[8] = 415; // G#
       note_freqs[9] = 440; // A
       note_freqs[10] = 466; // A#
       note_freqs[11] = 494; // B
   end

   // PWM output
   always @(posedge clk or posedge rst) begin
       if (rst) begin
           // Reset the counter and PWM output on reset
           counter <= 0;
           pwm_out <= 0;
       end else begin
           // Increment the counter on every clock cycle
           counter <= counter + 1'b1;

           // Set the duty cycle based on the frequency of the note
           duty_cycle <= note_freqs[note];

           // Generate the PWM signal based on the duty cycle
           pwm_out <= (counter < duty_cycle) ? 1'b1 : 1'b0;
       end
   end

endmodule
