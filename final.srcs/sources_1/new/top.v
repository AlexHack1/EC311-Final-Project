`timescale 1ns / 1ps

module top(
    input CLK100MHZ,       // FPGA board clock (assumed to be much higher than 1kHz)
    input rst_button,      // Reset button
    input next_note_button,// Button to change to the next note

   
    input PS2_CLK,
    input PS2_DATA,
    
    // outputs to board
    output [7:0] cathode_seg,   // 7-segment cathode outputs
    output [7:0] anode_seg,      // 7-segment anode outputs (8 bits since we include decimal point here)
    output wire AUD_PWM,         // Output to a speaker or an 
    output wire led0        // for debug
);

    reg [3:0] note = 0;          // Note storage
    reg [7:0] octave = 40; //octave storage
    wire clk_100kHz;
    wire clk_500Hz;
    wire [27:0] current_freq;
    wire [3:0] octave_for_display;
    assign octave_for_display = octave / 4'd10;
    
    
    wire deb_next_note;
    
    // for keyboard
    wire [31:0]keycode; //unique keycode
    reg CLK50MHZ = 0; 
    wire key_flag; //flag if key pressed
    
    // display mode gets tied to 7seg disp
    reg [2:0] disp_mode = 00;
    reg [2:0] wave_type = 00;
    
    
    //clk divider for PS2 Receiver
    always @(posedge(CLK100MHZ))begin
        CLK50MHZ<=~CLK50MHZ;
    end
    
    //PS2 Receiver for Keyboard
    PS2Receiver keyboard(
    .clk(CLK50MHZ),
    .kclk(PS2_CLK),
    .kdata(PS2_DATA),
    .keycodeout(keycode[31:0]),
    .changed(key_flag)
    );

    /// KEYBOARD STUFF /// 
    always @ (posedge key_flag) begin //keybinds
        case(keycode[7:0]) // only need to look at 8 bits of keycode
        
            // notes
            'h1C:  begin // a --> decrement octave and set note to b
                note <= 11;
                octave <= octave-5;
            end 
            'h1B:  note = 0;//s  --> C
            'h23:  note = 2;//d --> D
            'h2B:  note = 4;//f --> E
            'h34:  note = 5;//g --> F
            'h33:  note = 7;//h --> G
            'h3B:  note = 9;//j --> A
            'h42:  note = 11;//k --> B
            'h4B:  begin // l --> increment octave and set note to c
                note <= 0;
                octave <= octave+5;
            end 
            'h24: note = 1;// e --> C#/Dflat
            'h2D: note = 3;//r --> D#/Ef
            'h35: note = 6;//y --> F#/Gf
            'h3C: note = 8;//u --> G#/Af
            'h43: note = 10;//i --> A#/Bf


            'h6B: begin //numpad 4 go up by 3 tones (minor 3rd)
                if (note <9)
                    note = note +3;
                else begin
                    octave = octave + 5;
                    note = note-8; // in case of overflow, go down by 8 and increment octave
                    end

             end//numpad 7 go up by 3 tones (minor 3rd)        

            'h73: begin //numpad 5 --> up by 4 tones (maj 3rd)
                if (note < 8)
                    note = note +4;
                else begin
                    octave = octave + 5;
                    note = note-7; // octave up by 1 note -7 same as note+4 if overflow
                    end
              end

            'h74: begin //numpad 9 --> up by 7 tones (maj 5th)
                if (note < 5)
                    note = note +7;
                else begin
                    octave = octave + 5;
                    note = note-4;
                    end
              end
       


            
            //octaves
            'h16: octave = 10; // num 1 --> octave 1
            'h1E: octave = 20;
            'h26: octave = 30;
            'h25: octave = 40; // num 4 --> octave 4 (default)
            'h2E: octave = 50;
            'h36: octave = 60;
            'h3D: octave = 70; // num 7 --> octave 7
            
            // modes
            'h1a: disp_mode = 4'b00; // z --> mode 00 (show note and octave)
            'h22: disp_mode = 4'b01; // x --> mode 01 (show frequency)
            
            'h32: wave_type = 4'b00; // b --> 50% duty cycle (sqaure)
            'h31: wave_type = 4'b01; // n --> sine wave
            'h3A: wave_type = 4'b10; // m --> triable
                       
            default:;
        endcase
    
    end
    
    // for note generator
    clk_div my_clk_100kHz(
        .clk_in(CLK100MHZ),
        .clk_out(clk_100kHz)
    );
    
    // slow clock (500hz) for display   
    sev_clock my_sev_clk (
        .clock_in(CLK100MHZ),
        .clock_out(clk_500Hz)
    );

    // Instantiate note_generator with 100kHz clock
    note_generator #(
        .NOTE_COUNT(12),
        .PWM_RESOLUTION(8),
        .OCTAVE_MAX(7),
        .CLK_FREQUENCY(100000) // 100kHz clock
        //.DUTY_CYCLE(2)         // Duty cycle (for square wave = 2)
    ) my_note_generator (
        .clk(clk_100kHz),
        .rst(rst_button),
        .note(note),
        .octave_in(octave),
        .duty_cycle_type(wave_type),
        .pwm_out(AUD_PWM),
        .pwm_led(led0),
        .current_frequency(current_freq)
    );
    
    debouncer mydeb (
        .clk(CLK100MHZ),
        .button(next_note_button),
        .clean(deb_next_note)
    );
    
    
   
    wire [5:0] disp0, disp1, disp2, disp3, disp4, disp5, disp6, disp7;
    display_mode my_display_mode (
        .clk(clk_500Hz),
        .mode(disp_mode),
        .note(note),
        .octave(octave_for_display),
        .frequency(current_freq),
        .pwm_type(wave_type),
        .val_TBD0(disp0),
        .val_TBD1(disp1),
        .val_TBD2(disp2),
        .val_TBD3(disp3),
        .val_TBD4(disp4),
        .val_TBD5(disp5),
        .val_TBD6(disp6),
        .val_TBD7(disp7)
    );

    
    // 7 segment display using 5 bit BCD 
    // each digit is in correct order left to right dont move them
    segment_disp sevendisp (
        .val_TBD5(disp0),
        .val_TBD4(disp1),
        .val_TBD3(disp2),
        .val_TBD2(disp3),
        .val_TBD1(disp4),
        .val_TBD0(disp5),
        .val_TBD7(disp6), 
        .val_TBD6(disp7),

        .clock_in(clk_500Hz),
        .reset_in(rst_button),
        .cathode_out(cathode_seg),
        .anode_out(anode_seg)
    );


endmodule