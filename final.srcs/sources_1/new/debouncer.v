//
// NOTE we modified the Moore machine slightly when we ran this part on the FPGA. The original moore machine for p1 is in moore_FSM_OG and the new moore machine is moore_FSM
// This module we ran on the FPGA tied to the buttons.
//

`timescale 1ns / 1ps

module debouncer(
    input clk,
    input button,
    output reg clean 
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
