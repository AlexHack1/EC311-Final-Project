`timescale 1ns / 1ps

module top(
    input CLK100MHZ,          // FPGA board clock (assumed to be much higher than 1kHz)
    input rst_button,         // Reset button
    input next_note_button,   // Button to change to the next note
   
    input PS2_CLK,
    input PS2_DATA,
    
    // outputs to board
    output [7:0] cathode_seg, // 7-segment cathode outputs
    output [7:0] anode_seg,   // 7-segment anode outputs (8 bits since we include decimal point here)
    output wire AUD_PWM,      // Output to a speaker or an 
    output wire led0          // for debug - display pwm
    //output wire led1,       // for in playback (debug)
    //output wire led2        // for recording (debug)
);
    // STOREAGE
    reg [3:0] note = 0;    // Note storage
    reg [7:0] octave = 40; // octave storage
    
    
    reg octave_flag; //0 for octave dec, 1 for octave inc
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

    // for recording and playback
    /*
    reg start_recording = 0;
    reg stop_recording = 0;
    reg playback = 0;
    wire [3:0] playback_note;
    wire [7:0] playback_octave;
    reg in_playback_mode = 0; // 1 if in playback mode, 0 if not
    wire clk_50hz;
    clock_divider_50hz div50hz (
        .clk_500hz(clk_500Hz),
        .clk_50hz(clk_50hz)
    );
    
    // for debug
    assign led1 = in_playback_mode;
    assign led2 = start_recording;
    */
    
    
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

        // enter playback mode 
        // Left out due to an error where playback mode would:
        // 1. not exit when pressing the exit key
        // 2. play at the wrong freuqency
        /* if (playback) begin
            in_playback_mode <= 1;
        end else if (stop_recording || start_recording) begin
            in_playback_mode <= 0;
        end 
        // exit playback mode
        if (keycode[7:0] == 'h4D && in_playback_mode) begin // p--> exit playback
            in_playback_mode <= 0;
            playback <= 0;
        end */

        case(keycode[7:0]) // only need to look at 8 bits of keycode

            // note playback
            'h1C:  begin // a --> decrement octave and set note to b
                note <= 11;
                octave_flag <= 0;
                octave <= octave-5; // every 3 above a multiple of 10 means octave dec
            end 
            'h1B:  note = 0;//s  --> C
            'h23:  note = 2;//d --> D
            'h2B:  note = 4;//f --> E
            'h34:  note = 5;//g --> F
            'h33:  note = 7;//h --> G
            'h3B:  note = 9;//j --> A
            'h42:  note = 11;//k --> B
            'h4B:  begin // l --> increment octave and set note to c
                octave_flag <= 1;
                note <= 0;
                octave <= octave+5; // every 2 below a multiple of 10 means octave inc
            end 
            'h24: note = 1;// e --> C#/Dflat
            'h2D: note = 3;//r --> D#/Ef
            'h35: note = 6;//y --> F#/Gf
            'h3C: note = 8;//u --> G#/Af
            'h43: note = 10;//i --> A#/Bf

            //  NUMPAD - Left out due to these keys causing many incrementation and decrementation errors
            //  (Likely due to an issue with the debouncing of the keys)
            /*
            'h6B: begin //numpad 4 go up by 3 tones (minor 3rd)
                    note <= note + 3;
                if (note > 8) begin
                    octave <= octave + 5;
                    note <= 12 - note;
                end else begin
                    note <= note + 3;
                end
             end      
            'h73: begin //numpad 5 --> major third go up by 4 tones
                if (note > 7) begin
                    octave <= octave + 5;
                    note = 12 - note; 
                end else begin
                    note <= note + 4;
                end
                    
              end
            'h74: begin //numpad 6 --> up by 7 tones (maj 5th)
                if (note > 4) begin
                    octave <= octave + 5;
                    note <= 12 - note;
                end else begin
                    note <= note + 7;
                end
              end
            */

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


            // recording and playback keys
            /*
            'h5b: begin // ] --> start recording
                start_recording <= 1;
                stop_recording <= 0;
                playback <= 0;
                in_playback_mode <= 0;
            end
            'h54: begin // [ --> stop recording
                stop_recording <= 1;
                start_recording <= 0;
                playback <= 0;
                in_playback_mode <= 0;
            end
            'h44: begin // o --> start playback
                playback <= 1;
                start_recording <= 0;
                stop_recording <= 0;
                in_playback_mode <= 1;
            end
            */
                       
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

    // note generator module with parameters
    note_generator #(
        .NOTE_COUNT(12),
        .PWM_RESOLUTION(8),
        .OCTAVE_MAX(7),
        .CLK_FREQUENCY(100000) // 100kHz clock
    ) my_note_generator (
        .clk(clk_100kHz),
        .rst(rst_button),
        .note(in_playback_mode ? playback_note : note), // if in playback mode, use playback_note otherwise play note pressed
        .octave_in(in_playback_mode ? playback_octave : octave), // same for octave
        .duty_cycle_type(wave_type),
        .pwm_out(AUD_PWM),
        .pwm_led(led0),
        .current_frequency(current_freq),
        .octave_flag(octave_flag)
    );
    
    // debouncer for next note button (used in debug)
    /*
    debouncer mydeb (
        .clk(CLK100MHZ),
        .button(next_note_button),
        .clean(deb_next_note)
    );
    */
    
   
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

    // recording
    /*
    recording_module rec_module (
        .clk(clk_50hz),
        .start_recording(start_recording),
        .stop_recording(stop_recording),
        .playback(playback),
        .note(note),
        .octave(octave),
        .playback_note(playback_note),
        .playback_octave(playback_octave)
    );
    */

endmodule