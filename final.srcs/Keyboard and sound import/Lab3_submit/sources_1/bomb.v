`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2023 04:18:19 PM
// Design Name: 
// Module Name: bomb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bomb(
    
    input clk,
    input PS2_CLK,
    input PS2_DATA,
    input switch,
    
    output [6:0] cathode,
    output [7:0] anode,  
    output UART_TXD,
    output buzzer
    
    );
    
reg [15:0] counter;
reg CLK50MHZ=0;    
wire [31:0]keycode;
wire dp;
//reg [31:0] myreg;
wire fsmclk;
wire changed;

always @(posedge(clk))begin
    CLK50MHZ<=~CLK50MHZ;
//    myreg <= keycode;
end


PS2Receiver keyboard (
.clk(CLK50MHZ),
.kclk(PS2_CLK),
.kdata(PS2_DATA),
.keycodeout(keycode[31:0]),
.changed(changed)
);

  initial begin
    counter = 0;
//  myreg <= 0;
  end
  
  
  
  always @ (posedge changed) begin // keycode is a wire, always needs a reg
    case(keycode[7:0])
         'h75: counter = counter +1; // up arrow
         'h72: counter = counter -1; // down arrow
         'h6B: counter = 0; // left arrow
         'h74: counter = counter + 10; // right arrow
     endcase
  end
//  always @ (posedge switch)
//    counter = counter +1;

  
//   seg7decimal(counter,clk,cathode,anode,dp);
   faster_clock_divider fcd(clk,fsmclk);
   fsm myfsm(fsmclk,counter,cathode,anode);
   
 assign buzzer = counter ? 0:1;

endmodule
