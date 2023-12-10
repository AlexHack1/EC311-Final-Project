`timescale 1ns / 1ps

module note_generator #(
    parameter integer NOTE_COUNT = 12,
    parameter integer PWM_RESOLUTION = 8, // PWM resolution in bits
    parameter integer OCTAVE_MAX = 7, // Maximum octave (not used for now since we only shift by one octave)
    parameter integer CLK_FREQUENCY = 100000, // Clock frequency in Hz - 100kHz default
    //parameter integer DUTY_CYCLE = 2, //default duty cycle of 50% = 2 (meaning 2 is the divisor)
    parameter integer SINE_LUT_SIZE = 256 // Size of the sine LUT
)(
    input wire clk,
    input wire rst,
    input wire [3:0] note, // Note input (0-11 for C-B)

    input wire [3:0] duty_cycle_type, // 00 is 50% 01 is sine...
    input [2:0] octave_in,

    output reg pwm_out, // PWM output - can be tied directly to a speaker
    output wire pwm_led, //for testing
    output reg [31:0] current_frequency // Output current frequency
);

    assign pwm_led = pwm_out;

    //reg [PWM_RESOLUTION-1:0] counter = 0; // Counter for generating PWM signal
    reg [31:0] counter = 0;
    reg [31:0] frequency; // Frequency for the note
    reg [2:0] octave_reg = 3'd4; // Octave count (starting at middle C)
    
    
    // SINE //
    reg [7:0] sine_lut[SINE_LUT_SIZE-1:0];
    // Sine Wave Generator
    reg [7:0] sine_index = 0;
    wire [7:0] sine_value = sine_lut[sine_index];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sine_index <= 0;
        end else begin
            sine_index <= (sine_index + 1) % SINE_LUT_SIZE;
        end
    end
    
    
    // Frequency LUT for base octave (4th octave, ie middle C)
    integer base_freqs [0:NOTE_COUNT-1];
    initial begin
        // 100X Frequencies for the 4th octave 
        base_freqs[0] = 26163; // C
        base_freqs[1] = 27718; // C#
        base_freqs[2] = 29366; // D
        base_freqs[3] = 31113; // D#
        base_freqs[4] = 32963; // E
        base_freqs[5] = 34923; // F
        base_freqs[6] = 36999; // F#
        base_freqs[7] = 39200; // G
        base_freqs[8] = 41530; // G#
        base_freqs[9] = 44000; // A
        base_freqs[10] = 46616; // A#
        base_freqs[11] = 49388; // B
        
        sine_lut[0] = 50; sine_lut[1] = 51; sine_lut[2] = 52; sine_lut[3] = 54;
        sine_lut[4] = 55; sine_lut[5] = 56; sine_lut[6] = 57; sine_lut[7] = 59;
        sine_lut[8] = 60; sine_lut[9] = 61; sine_lut[10] = 62; sine_lut[11] = 63;
        sine_lut[12] = 65; sine_lut[13] = 66; sine_lut[14] = 67; sine_lut[15] = 68;
        sine_lut[16] = 69; sine_lut[17] = 70; sine_lut[18] = 71; sine_lut[19] = 72;
        sine_lut[20] = 74; sine_lut[21] = 75; sine_lut[22] = 76; sine_lut[23] = 77;
        sine_lut[24] = 78; sine_lut[25] = 79; sine_lut[26] = 80; sine_lut[27] = 81;
        sine_lut[28] = 82; sine_lut[29] = 83; sine_lut[30] = 84; sine_lut[31] = 84;
        sine_lut[32] = 85; sine_lut[33] = 86; sine_lut[34] = 87; sine_lut[35] = 88;
        sine_lut[36] = 89; sine_lut[37] = 89; sine_lut[38] = 90; sine_lut[39] = 91;
        sine_lut[40] = 92; sine_lut[41] = 92; sine_lut[42] = 93; sine_lut[43] = 94;
        sine_lut[44] = 94; sine_lut[45] = 95; sine_lut[46] = 95; sine_lut[47] = 96;
        sine_lut[48] = 96; sine_lut[49] = 97; sine_lut[50] = 97; sine_lut[51] = 97;
        sine_lut[52] = 98; sine_lut[53] = 98; sine_lut[54] = 99; sine_lut[55] = 99;
        sine_lut[56] = 99; sine_lut[57] = 99; sine_lut[58] = 99; sine_lut[59] = 100;
        sine_lut[60] = 100; sine_lut[61] = 100; sine_lut[62] = 100; sine_lut[63] = 100;
        sine_lut[60] = 100; sine_lut[61] = 100; sine_lut[62] = 100; sine_lut[63] = 100;
        sine_lut[68] = 100; sine_lut[69] = 100; sine_lut[70] = 99; sine_lut[71] = 99;
        sine_lut[72] = 99; sine_lut[73] = 99; sine_lut[74] = 99; sine_lut[75] = 98;
        sine_lut[76] = 98; sine_lut[77] = 97; sine_lut[78] = 97; sine_lut[79] = 97;
        sine_lut[80] = 96; sine_lut[81] = 96; sine_lut[82] = 95; sine_lut[83] = 95;
        sine_lut[84] = 94; sine_lut[85] = 94; sine_lut[86] = 93; sine_lut[87] = 92;
        sine_lut[88] = 92; sine_lut[89] = 91; sine_lut[90] = 90; sine_lut[91] = 89;
        sine_lut[92] = 89; sine_lut[93] = 88; sine_lut[94] = 87; sine_lut[95] = 86;
        sine_lut[96] = 85; sine_lut[97] = 84; sine_lut[98] = 84; sine_lut[99] = 83;
        sine_lut[100] = 82; sine_lut[101] = 81; sine_lut[102] = 80; sine_lut[103] = 79;
        sine_lut[104] = 78; sine_lut[105] = 77; sine_lut[106] = 76; sine_lut[107] = 75;
        sine_lut[108] = 74; sine_lut[109] = 72; sine_lut[110] = 71; sine_lut[111] = 70;
        sine_lut[112] = 69; sine_lut[113] = 68; sine_lut[114] = 67; sine_lut[115] = 66;
        sine_lut[116] = 65; sine_lut[117] = 63; sine_lut[118] = 62; sine_lut[119] = 61;
        sine_lut[120] = 60; sine_lut[121] = 59; sine_lut[122] = 57; sine_lut[123] = 56;
        sine_lut[124] = 55; sine_lut[125] = 54; sine_lut[126] = 52; sine_lut[127] = 51;
        sine_lut[128] = 50; sine_lut[129] = 49; sine_lut[130] = 48; sine_lut[131] = 46;
        sine_lut[132] = 45; sine_lut[133] = 44; sine_lut[134] = 43; sine_lut[135] = 41;
        sine_lut[136] = 40; sine_lut[137] = 39; sine_lut[138] = 38; sine_lut[139] = 37;
        sine_lut[140] = 35; sine_lut[141] = 34; sine_lut[142] = 33; sine_lut[143] = 32;
        sine_lut[144] = 31; sine_lut[145] = 30; sine_lut[146] = 29; sine_lut[147] = 28;
        sine_lut[148] = 26; sine_lut[149] = 25; sine_lut[150] = 24; sine_lut[151] = 23;
        sine_lut[152] = 22; sine_lut[153] = 21; sine_lut[154] = 20; sine_lut[155] = 19;
        sine_lut[156] = 18; sine_lut[157] = 17; sine_lut[158] = 16; sine_lut[159] = 16;
        sine_lut[160] = 15; sine_lut[161] = 14; sine_lut[162] = 13; sine_lut[163] = 12;
        sine_lut[164] = 11; sine_lut[165] = 11; sine_lut[166] = 10; sine_lut[167] = 9;
        sine_lut[168] = 8; sine_lut[169] = 8; sine_lut[170] = 7; sine_lut[171] = 6;
        sine_lut[172] = 6; sine_lut[173] = 5; sine_lut[174] = 5; sine_lut[175] = 4;
        sine_lut[176] = 4; sine_lut[177] = 3; sine_lut[178] = 3; sine_lut[179] = 3;
        sine_lut[180] = 2; sine_lut[181] = 2; sine_lut[182] = 1; sine_lut[183] = 1;
        sine_lut[184] = 1; sine_lut[185] = 1; sine_lut[186] = 1; sine_lut[187] = 0;
        sine_lut[188] = 0; sine_lut[189] = 0; sine_lut[190] = 0; sine_lut[191] = 0;
        sine_lut[188] = 0; sine_lut[189] = 0; sine_lut[190] = 0; sine_lut[191] = 0;
        sine_lut[196] = 0; sine_lut[197] = 0; sine_lut[198] = 1; sine_lut[199] = 1;
        sine_lut[200] = 1; sine_lut[201] = 1; sine_lut[202] = 1; sine_lut[203] = 2;
        sine_lut[204] = 2; sine_lut[205] = 3; sine_lut[206] = 3; sine_lut[207] = 3;
        sine_lut[208] = 4; sine_lut[209] = 4; sine_lut[210] = 5; sine_lut[211] = 5;
        sine_lut[212] = 6; sine_lut[213] = 6; sine_lut[214] = 7; sine_lut[215] = 8;
        sine_lut[216] = 8; sine_lut[217] = 9; sine_lut[218] = 10; sine_lut[219] = 11;
        sine_lut[220] = 11; sine_lut[221] = 12; sine_lut[222] = 13; sine_lut[223] = 14;
        sine_lut[224] = 15; sine_lut[225] = 16; sine_lut[226] = 16; sine_lut[227] = 17;
        sine_lut[228] = 18; sine_lut[229] = 19; sine_lut[230] = 20; sine_lut[231] = 21;
        sine_lut[232] = 22; sine_lut[233] = 23; sine_lut[234] = 24; sine_lut[235] = 25;
        sine_lut[236] = 26; sine_lut[237] = 28; sine_lut[238] = 29; sine_lut[239] = 30;
        sine_lut[240] = 31; sine_lut[241] = 32; sine_lut[242] = 33; sine_lut[243] = 34;
        sine_lut[244] = 35; sine_lut[245] = 37; sine_lut[246] = 38; sine_lut[247] = 39;
        sine_lut[248] = 40; sine_lut[249] = 41; sine_lut[250] = 43; sine_lut[251] = 44;
        sine_lut[252] = 45; sine_lut[253] = 46; sine_lut[254] = 48; sine_lut[255] = 49;
        
    end

    // octave adjustment based on octave_in
    always @ (posedge clk) begin
        octave_reg <= octave_in;
        if (rst) begin // Reset to middle C
                frequency = base_freqs[note];
        end
        case(octave_reg)
            0: frequency = base_freqs[note]/16;
            1: frequency = base_freqs[note]/8;
            2: frequency = base_freqs[note]/4;
            3: frequency = base_freqs[note]/2;
            4: frequency = base_freqs[note];
            5: frequency = base_freqs[note]*2;
            6: frequency = base_freqs[note]*4;
            7: frequency = base_freqs[note]*8;
            default:;
        endcase
         current_frequency = frequency;
    end


    // PWM Output Block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            pwm_out <= 0;
        end else begin
            counter <= counter + 1'b1; // increment counter
    
            // Reset the counter when the full period is reached
            if (counter >= ((CLK_FREQUENCY*100) / (frequency))) begin
                counter <= 0;
            end
    
            // Set pwm_out high depending on duty cycle mode
            case (duty_cycle_type)
                2'b00: begin
                        // 50% Duty Cycle - square (replace 2 with divisor for duty cycle)
                        pwm_out <= (counter < ((CLK_FREQUENCY*100) / (frequency) / 2)) ? 1'b1 : 1'b0;
                    end
                2'b01: begin
                        // sine duty cycle
                        pwm_out <= (counter < ((CLK_FREQUENCY*100*100) / (frequency) * sine_value / 1)) ? 1'b1 : 1'b0;
                    end  
                default: begin
                    // Default to 50% Duty Cycle
                    pwm_out <= (counter < ((CLK_FREQUENCY*100) / (frequency) / 2)) ? 1'b1 : 1'b0;
                end 
           endcase 
        end
    end

endmodule