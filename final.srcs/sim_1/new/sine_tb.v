module tb;

    // Inputs
    reg Clk;

    // Outputs
    wire [7:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    sine_wave_gen uut (
        .Clk(Clk), 
        .data_out(data_out)
    );

    //Generate a clock with 10 ns clock period.
    initial Clk = 0;
    always #5 Clk = ~Clk;
    
endmodule