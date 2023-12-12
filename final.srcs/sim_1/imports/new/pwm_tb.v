// better pwm generator with variable duty cycle (increaseing wave from presentation)

`timescale 1ns / 1ps

module pwm_generator_tb;

    parameter PWM_RESOLUTION = 8;
    parameter CLK_PERIOD = 10;    // Clock period in ns (100 MHz clock)
    parameter integer MAX_DUTY_CYCLE = 1 << PWM_RESOLUTION; // Maximum duty cycle value (2^PWM_RESOLUTION)
    parameter integer SIM_STEP = CLK_PERIOD * 256; // Time step to change the duty cycle (256 clock cycles)
    parameter integer SIM_DURATION = SIM_STEP * MAX_DUTY_CYCLE;                                            

    reg clk = 0;
    reg rst = 1;
    reg [PWM_RESOLUTION-1:0] duty_cycle = 0;

    wire pwm_out;

    pwm_generator #(.PWM_RESOLUTION(PWM_RESOLUTION)) uut (
        .clk(clk),
        .rst(rst),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

    // simulate a 100 MHz hardware clock
    always #(CLK_PERIOD / 2) clk = ~clk;

    // increment duty cycle by 1 every SIM_STEP - for display only, real code would have to change duty_cycle but it looks good in presentation
    always #(SIM_STEP) if (!rst) duty_cycle <= duty_cycle + 1;

    initial begin
        // reset for a bit
        #(CLK_PERIOD * 5);
        rst = 0;
        #(SIM_DURATION);
        $finish;
    end

    initial begin
        $monitor("Time = %t | Duty Cycle = %0d | PWM Out = %b | Expected Average Voltage = %0d%% Vdd",
                 $time, duty_cycle, pwm_out, (duty_cycle * 100) / MAX_DUTY_CYCLE);
    end

endmodule
