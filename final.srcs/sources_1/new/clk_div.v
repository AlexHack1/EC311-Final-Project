module clk_div(
    input wire clk_in,  // Input clock (100 MHz)
    output reg clk_out  // Output clock (100 kHz)
);

    // Divider value for 100MHz to 100kHz
    // 100 MHz / 100 kHz = 1000, but divide by 500 for toggling every half period
    reg [9:0] counter = 0; // 10-bit counter for division by 1000
    parameter DIVIDE_VALUE = 500; // Half of 1000 for 50% duty cycle

    always @(posedge clk_in) begin
        counter <= counter + 1;
        if (counter >= DIVIDE_VALUE - 1) begin
            counter <= 0;
            clk_out <= ~clk_out; // Toggle the output clock
        end
    end

endmodule
