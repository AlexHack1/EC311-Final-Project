# Project Name: Keyboard Synthesizer
## Team Members:
- James Conlon
- Alexander Mack
- Ethan Levine
- Michael Barany
## Project Demo Video:
- INSERT LINK HERE
## How To Run Project
- NOTE: this project is only compatible with the Artix-7 xc7a100tcsg324-1 FPGA
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
8. Use the following key map to play the keyboard: INSERT KEYBOARD MAP THAT JAMES MADE
   - The home row (S, D, F, G, H, J, K) cooresponds to the white keys (C, D, E, F, G, A, B)
   - The row above (E, R, Y, U, I) cooresponds to the black keys (C#, D#, F#, G#, A#)
   - The number row keys (1, 2, 3, 4, 5, 6, 7, 8) are used to set the octave, A and L keys are used to decrement and increment the octave, respectively
   - The B, N, and M keys are used to switch between waveforms (square, sine, triangle)
   - The numpad keys (4, 5, 6) are used to play different intervals (M 3rd, m 3rd, M 5th)
9. Happy playing!
## Code Structure
- Block Diagram: https://docs.google.com/document/d/166IRrm7VCYgW_miiGuuvlWs8nWEqg8Q95AVZoADESpk/edit?usp=sharing
- Top module is used to accept user inputs from keyboard, and send those inputs to notegenerator to play the correct note and octave
- wave_lut module is a lookup table used to create different waveforms (sine, triangle). Toggling between different waveforms will change the sound type
- idk how to write this part
## Other
- This keyboard can be used by physically disabled people
- [Presentation](https://docs.google.com/presentation/d/1KdgBcJ44fEv6qghZ1U9QxBsIMdMlq52oRwmxUYjcXJE/edit?usp=sharing)
- [Planning Doc](https://docs.google.com/document/d/166IRrm7VCYgW_miiGuuvlWs8nWEqg8Q95AVZoADESpk/edit?usp=sharing)
