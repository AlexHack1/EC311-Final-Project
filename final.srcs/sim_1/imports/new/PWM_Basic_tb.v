// Basic square wave generator with a variable duty cycle input

`timescale 1ns / 1ps

module basic_pwm_generator_tb;

    parameter PWM_RESOLUTION = 8; // 8 bit
    parameter CLK_PERIOD = 10;    // Clock period in ns (100 MHz clock for PWM frequency >= 50 kHz)
    parameter integer MAX_DUTY_CYCLE = 1 << PWM_RESOLUTION;
    parameter integer SIM_STEP = CLK_PERIOD * 256; // Time step to change the duty cycle
    parameter integer SIM_DURATION = SIM_STEP * MAX_DUTY_CYCLE * 2; // Total simulation time should be enought to see a full duty cycle range (*2)

    reg clk = 0;
    reg rst = 1;

    wire pwm_out;
    reg [PWM_RESOLUTION-1:0] duty_cycle = 0; // Duty cycle for PWM

    basic_pwm_generator #(.PWM_RESOLUTION(PWM_RESOLUTION)) uut (
        .clk(clk),
        .rst(rst),
        .pwm_out(pwm_out)
    );

    // simulate a 100 MHz hardware clock
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        // reset for a bit
        #(CLK_PERIOD * 5);
        rst = 0;

        // Run the simulation for 2 * MAX_DUTY_CYCLE * SIM_STEP clock cycles to see the full duty cycle range *2
        #(SIM_DURATION);
        $finish;
    end

    // lets us compare much easier than using waveform
    initial begin
        $monitor("Time = %t | Duty Cycle = %0d | PWM Out = %b | Expected Average Voltage = %0d%% Vdd",
                 $time, duty_cycle, pwm_out, (duty_cycle * 100) / MAX_DUTY_CYCLE);
    end

endmodule
