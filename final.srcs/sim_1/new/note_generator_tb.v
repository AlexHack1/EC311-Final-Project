`timescale 1ns / 1ps

module tb_note_generator;
   reg clk;
   reg rst;
   reg [3:0] note;
   wire pwm_out;

   note_generator uut (
       .clk(clk),
       .rst(rst),
       .note(note),
       .pwm_out(pwm_out)
   );

   // simulated 100MHz clock
   always begin
       #10 clk = ~clk;
   end

   initial begin
       clk = 0;
       rst = 1;
       note = 0;

       // Wait a bit for a reset
       #10 rst = 0;

       // notes
       for (note = 0; note < 12; note = note + 1) begin
           #10;
           $display("Note: %d, Frequency: %d Hz", note, uut.note_freqs[note]);
       end

       #10 $finish;
   end
endmodule
