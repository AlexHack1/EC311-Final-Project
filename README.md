# Project Name: Keyboard Synthesizer
## Team Members:
- James Conlon
- Alexander Mack
- Ethan Levine
- Michael Barany
## Project Demo Video:
- INSERT LINK HERE
## How To Run Project
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
8. Use this [key map](http://www.keyboard-layout-editor.com/##@@=Esc&_x:1%3B&=F1&=F2&=F3&=F4&_x:0.5%3B&=F5&=F6&=F7&=F8&_x:0.5%3B&=F9&=F10&=F11&=F12&_x:0.25%3B&=PrtSc&=Scroll%20Lock&=Pause%0ABreak%3B&@_y:0.5%3B&=~%0A%60&=Oct%201&=Oct%202&=Oct%203&=Oct%204&=Oct%205&=Oct%206&=Oct%207&=Oct%208&=(%0A9&=)%0A0&=%2F_%0A-&=+%0A%2F=&_w:2%3B&=Backspace&_x:0.25%3B&=Insert&=Home&=PgUp&_x:0.25%3B&=Num%20Lock&=%2F%2F&=*&=-%3B&@_w:1.5%3B&=Tab&_a:7%3B&=&=&_a:4%3B&=C%23%2F%2FDf&=D%23%2F%2FEf&_a:7%3B&=&_a:4%3B&=F%23%2F%2FGf&_a:7%3B&=&_a:4%3B&=A%23%2F%2FBf&_a:7%3B&=&=&_a:4%3B&=%7B%0A%5B&=%7D%0A%5D&_w:1.5%3B&=%7C%0A%5C&_x:0.25%3B&=Delete&=End&=PgDn&_x:0.25%3B&=7%0AHome&=8%0A%E2%86%91&=9%0APgUp&_h:2%3B&=+%3B&@_w:1.75%3B&=Caps%20Lock&=Dec.%20Octave&=C&=D&=E&=F&=G&=A&=B&=Inc.%20Octave&=%2F:%0A%2F%3B&=%22%0A'&_w:2.25%3B&=Enter&_x:3.5%3B&=4%0A%E2%86%90&=5&=6%0A%E2%86%92%3B&@_w:2.25%3B&=Shift&=Show%20Note%2F%2F%0AOctave&=Show%20Freq.&_a:7%3B&=&=&_a:4%3B&=Square%20Duty%20Cycle&=Sine%20Duty%20Cycle&_a:7%3B&=&=&=&_a:4%3B&=%3F%0A%2F%2F&_w:2.75%3B&=Shift&_x:1.25%3B&=%E2%86%91&_x:1.25%3B&=1%0AEnd&=2%0A%E2%86%93&=3%0APgDn&_h:2%3B&=Enter%3B&@_w:1.25%3B&=Ctrl&_w:1.25%3B&=Win&_w:1.25%3B&=Alt&_a:7&w:6.25%3B&=&_a:4&w:1.25%3B&=Alt&_w:1.25%3B&=Win&_w:1.25%3B&=Menu&_w:1.25%3B&=Ctrl&_x:0.25%3B&=%E2%86%90&=%E2%86%93&=%E2%86%92&_x:0.25&w:2%3B&=0%0AIns&=.%0ADel) for playing the keyboard
   - The home row (S, D, F, G, H, J, K) cooresponds to the white keys (C, D, E, F, G, A, B)
   - The row above (E, R, Y, U, I) cooresponds to the black keys (C#, D#, F#, G#, A#)
   - The number row keys (1, 2, 3, 4, 5, 6, 7, 8) are used to set the octave, A and L keys are used to decrement and increment the octave, respectively
   - The B, N, and M keys are used to switch between waveforms (square, sine, triangle)
   - The numpad keys (4, 5, 6) are used to play different intervals (M 3rd, m 3rd, M 5th)
9. Happy playing!
## Code Structure
- [Block Diagram](https://docs.google.com/document/d/166IRrm7VCYgW_miiGuuvlWs8nWEqg8Q95AVZoADESpk/edit?usp=sharing)
- Top module is used to accept user inputs from keyboard, and send those inputs to notegenerator to play the correct note and octave
- wave_lut module is a lookup table used to create different waveforms (sine, triangle). Toggling between different waveforms will change the sound type
- idk how to write this part
## Other
- This keyboard can be used by physically disabled people
- [Presentation](https://docs.google.com/presentation/d/1KdgBcJ44fEv6qghZ1U9QxBsIMdMlq52oRwmxUYjcXJE/edit?usp=sharing)
- [Planning Doc](https://docs.google.com/document/d/166IRrm7VCYgW_miiGuuvlWs8nWEqg8Q95AVZoADESpk/edit?usp=sharing)
- [Meeting Minutes](https://docs.google.com/document/d/1sm5ls5zhQ8x1Nxw--W5M_PYoI4fzIjPUxbyc21xwfzI/edit?usp=sharing)
