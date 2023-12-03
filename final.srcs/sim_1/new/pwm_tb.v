`timescale 1ns / 1ps

module pwm_generator_tb;

    parameter PWM_RESOLUTION = 8; // 8-bit resolution
    parameter CLK_PERIOD = 10;    // Clock period in ns (100 MHz clock for PWM frequency >= 50 kHz)
    parameter integer MAX_DUTY_CYCLE = 1 << PWM_RESOLUTION; // Maximum duty cycle value
    parameter integer SIM_STEP = CLK_PERIOD * 256; // Time step to change the duty cycle
    parameter integer SIM_DURATION = SIM_STEP * MAX_DUTY_CYCLE * 2; // I want to run sim for 2 cycles (1310720 ns = 1.31 ms)

    reg clk = 0;
    reg rst = 1;

    wire pwm_out;
    reg [PWM_RESOLUTION-1:0] duty_cycle = 0; // Duty cycle for PWM

    pwm_generator #(.PWM_RESOLUTION(PWM_RESOLUTION)) uut (
        .clk(clk),
        .rst(rst),
        .pwm_out(pwm_out)
    );

    // simulated hardware clock of 100 MHz (10 ns period)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Duty cycle increment logic every SIM_STEP (this would need to be connected to a potentiometer in hardware)
    always #(SIM_STEP) duty_cycle <= duty_cycle + 1;

    // Connect duty cycle to UUT (if needed)
    always @(posedge clk) begin
        if (rst) begin
            uut.duty_cycle <= 0;
        end else begin
            uut.duty_cycle <= duty_cycle;
        end
    end

    initial begin
        // reset at start for a moment
        #(CLK_PERIOD * 5);
        rst = 0;

        // Run the simulation for the duration defined above
        #(SIM_DURATION);
    
        $finish;
    end

    initial begin
        $monitor("Time = %t | Duty Cycle = %0d | PWM Out = %b | Expected Average Voltage = %0d%% Vdd",
                 $time, duty_cycle, pwm_out, (duty_cycle * 100) / MAX_DUTY_CYCLE);
    end

endmodule
