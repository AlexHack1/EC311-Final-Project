Names: Alexander Hack, Michael Barany
BU IDS: U98453597,U72972436

Lab 3: Keyboard controlled counter that displays on 7seg display with buzzer

For Lab3, we made a counter that takes input from the arrow keys on the keyboard.
By pressing the up arrow, the count increments.
By pressing the down arrow, the count decrements. 
Pressing the right arrow adds 10 to the counter.
Pressing left arrow brings the counter to 0.

When the counter equals 0, the buzzer will sound.

Organization
The sources folder contains the top module, 'bomb', which instantiates the PS2 receiver module, the 'faster clock' module, and the 'fsm module'.

The PS2 receiver uses the debouncer and the fsm uses the decoder.

Contributions
The PS2 receiver and some of the framework for integrating that signal in the 'bomb' module come from digilent inc
on github: https://github.com/Digilent/Nexys-A7-100T-Keyboard/blob/master/src/hdl/Seg_7_Display.v

We completed Chris's FSM module to display values across four digits of the 7seg display.

Alex and Michael worked hard to debug the PS2 receiver and make the case statement in the buzzer module 
Michael made the arduino code for the buzzer and Alex wired it up and changed the constraints file accordingly. 
Many other files were used in the development of the final design. Alex worked on a key_read module which was used
as a basis for the overall top module. 