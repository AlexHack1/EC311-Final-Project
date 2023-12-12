// Unused in the final project
// The recording works and we got playback, but we had to change the input clock to 50Hz
// The note generation is 100kHz, but the recording and playback is 50Hz which is why he had trouble with output
// We had to scale down to 50Hz because 10kHz would use way too much memory or only be able to record music for milliseconds
// However, that means the playback was at the wrong frequency and we were unable to fix it

`timescale 1ps/1ps

module recording_module(
    input wire clk,             // 50 hz
    input wire start_recording,
    input wire stop_recording,
    input wire playback,
    input wire [3:0] note,      // Note to record
    input wire [7:0] octave,    // Octave to record
    output reg [3:0] playback_note,
    output reg [7:0] playback_octave
);

    localparam MAX_NOTES = 1000; // 1000 notes is about 20 seconds of recording given 50Hz clock 
    reg [3:0] note_log[0:MAX_NOTES-1];
    reg [7:0] octave_log[0:MAX_NOTES-1];
    reg [31:0] timestamp_log[0:MAX_NOTES-1];
    reg [31:0] current_time = 0;
    reg recording = 0;
    reg [31:0] playback_time = 0; // elapsed time during playback
    integer playback_index = 0;
    integer i;

    // Record notes block
    always @(posedge clk) begin
        if (start_recording) begin
            recording <= 1;
            current_time <= 0;
            i <= 0;
        end
        else if (stop_recording) begin
            recording <= 0;
        end
        else if (recording && i < MAX_NOTES) begin
            note_log[i] <= note;
            octave_log[i] <= octave;
            timestamp_log[i] <= current_time;
            i <= i + 1;
        end
        current_time <= current_time + 1;
    end

    // playback logic
    always @(posedge clk) begin
        if (playback) begin
            // Starting playback
            if (playback_index == 0) begin
                playback_time <= 0; // Reset playback time
            end
            playback_time <= playback_time + 1;

            // Playing back a note
            if (playback_index < i && playback_time >= timestamp_log[playback_index]) begin
                playback_note <= note_log[playback_index];
                playback_octave <= octave_log[playback_index];
                playback_index <= playback_index + 1;
            end
        end else begin
            // Reset when playback stops or finishes
            playback_index <= 0;
            playback_time <= 0;
        end
    end

endmodule
