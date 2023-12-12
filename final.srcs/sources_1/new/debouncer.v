// Unused in project, but this is another debouncer we were working with
// for the keyboard from lab 4.

`timescale 1ns / 1ps

module debouncer(
    input clk,
    input button,
    output reg clean //clean signal, high or low
    );
    reg [19:0]deb_count;
    reg output_exist; // indicates if the clean output is set
    reg [19:0] max = 20'd1000000; //modified to create a debounce time of 10 ms.
    
    initial begin
        clean = 0;
    end
    always @(posedge clk) begin
        if(button == 1'b1) begin
            if(output_exist == 1'b0) begin
                if(deb_count == max) begin
                    clean = 1;
                    deb_count = 0;
                    output_exist = 1;
                end else begin
                    deb_count = deb_count + 20'b00001;
                end
            end else begin
                if(clean == 1'b1)
                    clean = 1;
                else
                    clean = 0;
            end 
        end else begin
            deb_count = 0;
            output_exist = 0;
            clean = 0;
        end
    end
    
endmodule
