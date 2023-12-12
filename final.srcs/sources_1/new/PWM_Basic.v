// Basic square wave generator with a variable duty cycle input
// Used for presentation but not on FPGA
// We adapted for square wave

module basic_pwm_generator #(
    parameter integer PWM_RESOLUTION = 8 // Use 8 bits for resolution
)(
    input wire clk,
    input wire rst,
    output reg pwm_out
);

    reg [PWM_RESOLUTION-1:0] duty_cycle;
    reg [PWM_RESOLUTION-1:0] counter;

    // PWM output logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            pwm_out <= 0;
        end else begin
            counter <= counter + 1'b1;

            if (counter < duty_cycle) begin
                pwm_out <= 1'b1;
            end else begin
                pwm_out <= 1'b0;
            end
        end
    end

    // Duty cycle update logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            duty_cycle <= 0;
        end else if (counter == {PWM_RESOLUTION{1'b1}} - 1) begin
            // Update duty cycle when counter is about to roll over
            duty_cycle <= duty_cycle + 1'b1;
        end
    end

endmodule
