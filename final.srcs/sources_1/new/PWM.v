module pwm_generator (
    input clk,
    input reset,
    input [7:0] duty_cycle, // 8-bit duty cycle  (0-255)
    output reg pwm_signal
);

// 8 bit counter
reg [7:0] counter = 0;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        pwm_signal <= 0;
    end else begin
        counter <= counter + 1'b1;
        pwm_signal <= (counter < duty_cycle) ? 1'b1 : 1'b0; // PWM signal is high when counter is less than duty cycle
    end
end

endmodule