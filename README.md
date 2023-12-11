# Project Name: Keyboard Synthesizer
## Team Members:
- James Conlon
- Alexander Mack
- Ethan Levine
- Michael Barany
## Project Demo Video:
- INSERT LINK HERE
## How To Run Project:
_Note: this project is only compatible with the Artix-7 xc7a100tcsg324-1 FPGA_  
1. Clone this repo into some directory on your machine
```bash
git clone https://github.com/AlexHack1/EC311-Final-Project.git
```
2. Create a new Vivado project (do not specify sources at this time)
3. Import the design and constraint source files from the cloned repo
4. Synthesize the project then generate the bitstream
5. Open the hardware manager and program the device using the bitstream
6. Plug in either a speaker or headphones to the audio jack on the FPGA (should be located on the back right corner)
7. Plug in a standard size QWERTY keyboard to the FPGA - the keyboard must have numpad and arrow keys
8. Use this [key map](http://www.keyboard-layout-editor.com/##@@=Esc&_x:1%3B&=F1&=F2&=F3&=F4&_x:0.5%3B&=F5&=F6&=F7&=F8&_x:0.5%3B&=F9&=F10&=F11&=F12&_x:0.25%3B&=PrtSc&=Scroll%20Lock&=Pause%0ABreak%3B&@_y:0.5&a:7%3B&=&_a:4%3B&=Oct%201&=Oct%202&=Oct%203&=Oct%204&=Oct%205&=Oct%206&=Oct%207&_a:7%3B&=&=&_a:4%3B&=Start%20Play%0Aback&=Stop%20Record&=Record&_a:7&w:2%3B&=&_x:0.25&a:4%3B&=Insert&=Home&=PgUp&_x:0.25&a:7%3B&=&=&=&=%3B&@_w:1.5%3B&=&=&=&_a:4%3B&=C%23%2F%2FDf&=D%23%2F%2FEf&_a:7%3B&=&_a:4%3B&=F%23%2F%2FGf&_a:7%3B&=&_a:4%3B&=A%23%2F%2FBf&_a:7%3B&=&_a:4%3B&=Stop%20Play%0Aback&=%7B%0A%5B&_a:7%3B&=&_w:1.5%3B&=&_x:0.25&a:4%3B&=Delete&=End&=PgDn&_x:0.25&a:7%3B&=&=&=&_h:2%3B&=%3B&@_w:1.75%3B&=&_a:4%3B&=Dec.%20Octave&=C&=D&=E&=F&=G&=A&=B&=Inc.%20Octave&=%2F:%0A%2F%3B&_a:7%3B&=&_w:2.25%3B&=&_x:3.5&a:4%3B&=Up%20minor%20third&=Up%20major%20third&=Up%20major%20fifth%3B&@_a:7&w:2.25%3B&=&_a:4%3B&=Show%20Note%2F%2F%0AOctave&=Show%20Freq.&_a:7%3B&=&=&_a:4%3B&=Square%20Duty%20Cycle&=Sine%20Duty%20Cycle&_a:7%3B&=&=&=&=&_w:2.75%3B&=&_x:1.25&a:4%3B&=%E2%86%91&_x:1.25&a:7%3B&=&=&=&_h:2%3B&=%3B&@_w:1.25%3B&=&_w:1.25%3B&=&_w:1.25%3B&=&_w:6.25%3B&=&_w:1.25%3B&=&_w:1.25%3B&=&_w:1.25%3B&=&_w:1.25%3B&=&_x:0.25&a:4%3B&=%E2%86%90&=%E2%86%93&=%E2%86%92&_x:0.25&a:7&w:2%3B&=&=) for playing the keyboard
    ![keyboard-layout](https://github.com/AlexHack1/EC311-Final-Project/assets/66924033/c727ab0a-c748-4651-9aa4-1efc3cc0839b)
   - The home row (S, D, F, G, H, J, K) corresponds to the white keys (C, D, E, F, G, A, B)
   - The row above (E, R, Y, U, I) corresponds to the black keys (C#, D#, F#, G#, A#)
   - The number row keys (1, 2, 3, 4, 5, 6, 7, 8) are used to set the octave
   - A and L keys are used to decrement and increment the octave, respectively
   - The B, N, and M keys are used to switch between waveforms (square, sine, triangle)
   - The numpad keys (4, 5, 6) are used to play different intervals (M 3rd, m 3rd, M 5th)

10. Happy playing!
## Code Structure:
![image](https://github.com/AlexHack1/EC311-Final-Project/assets/101854509/f2fd01d9-53f6-4c1c-8b6b-1733c4ec5f26)  
### Top Module
- The top module is used to accept user inputs from keyboard, and send those inputs to notegenerator module to play the correct note and octave. 

### Note Generator Module
- The note generator is the most complex module. It is used to generate the correct frequency for the note and octave that is being played. We use LUTs for 4th octave note frequency and also LUTs for both a sine wave and a triangle wave duty cycle.
- We implement 3 different duty cycles: 
   1. Square: A 50% duty cycle is relatively simple to implement since it does not require a LUT or any calculation.
   2. Sine: A sine wave is more complex. We use a LUT to generate the correct duty cycle for the sine wave. We use a 256x8 LUT to generate the correct duty cycle for the sine wave. We use the following equation to generate the correct duty cycle for the sine wave:
   ```verilog
   pwm_out <= (counter < ((CLK_FREQUENCY*1) / (frequency) * sine_value / 1)) ? 1'b1 : 1'b0;
   ```
   3. Triangle: A triangle wave also complex. We use a LUT to generate the correct duty cycle for the triangle wave. We use a 256x8 LUT to generate the correct duty cycle for the triangle wave. We use the following equation to generate the correct duty cycle for the triangle wave:
   ```verilog
   pwm_out <= (counter < ((CLK_FREQUENCY*1) / (frequency) * triangle_value / 1)) ? 1'b1 : 1'b0;
   ``` 
- We also implement octave shifting in this module. Rather than using a excessively large LUT, we reuse the 4th octave LUT and shift the octave up or down depending on the octave that is being played.

### Display Mode Module
- We implement 2 different display modes: 
   1. Show Note/Octave: This mode uses the first 4 displays to show note and octave and the last 4 displays to display the type of waveform (square, sine, triangle) that is being played. The triangle waveform does not really look like a triangle.
   2. Show Frequency: This mode displays frequency calculated in decimal such as `F00261.63` for a C in 4th octave.
### Everything else
- wave_lut module is a lookup table used to create different waveforms (sine, triangle). Toggling between different waveforms will change the sound type

## Outside Sources:
### Code Used:
- [Keyboard PS/2](https://github.com/Digilent/Nexys-A7-50T-Keyboard/tree/master): With modification
### Resources:
- [Digital Audio 101: Playing Audio From A Microcontroller](https://blog.tarkalabs.com/digital-audio-101-playing-audio-from-a-microcontroller-5df1463616c)
- [Function_Generator_SystemVerilog](https://github.com/JonathanHonrada/Function_Generator_SystemVerilog)
- [Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)
- [PWM Modulation](https://pcbheaven.com/wikipages/PWM_Modulation/)
- [Pulse Width Modulation & FPGA](https://www.compadre.org/advlabs/bfy/files/BFYHandout.pdf)

## Other:
- [Presentation](https://docs.google.com/presentation/d/1KdgBcJ44fEv6qghZ1U9QxBsIMdMlq52oRwmxUYjcXJE/edit?usp=sharing)
- [Planning Doc](https://docs.google.com/document/d/166IRrm7VCYgW_miiGuuvlWs8nWEqg8Q95AVZoADESpk/edit?usp=sharing)
- [Meeting Minutes](https://docs.google.com/document/d/1sm5ls5zhQ8x1Nxw--W5M_PYoI4fzIjPUxbyc21xwfzI/edit?usp=sharing)
