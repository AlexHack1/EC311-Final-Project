// Basic PWM generator with a variable duty cycle input
// Used for presentation and adapted for sine and trinagle waves
// Not used on FPGA

module pwm_generator #(
    parameter integer PWM_RESOLUTION = 8 // default 8 bit
)(
    input wire clk,
    input wire rst,
    input wire [PWM_RESOLUTION-1:0] duty_cycle, // duty cycle input (0 to 2^PWM_RESOLUTION-1)
    output reg pwm_out
);

    reg [PWM_RESOLUTION-1:0] counter;    // Counter for generating PWM signal

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the counter and PWM output on reset
            counter <= 0;
            pwm_out <= 0;
        end else begin
            // Increment the counter on every clock cycle
            counter <= counter + 1'b1;

            // Generate the PWM signal based on the duty cycle
            pwm_out <= (counter < duty_cycle) ? 1'b1 : 1'b0;
        end
    end

endmodule
