`timescale 1ps/1ps

module recording_module(
    input wire clk,
    input wire start_recording, // start recording
    input wire stop_recording,  // stop recording
    input wire playback,        // start playback
    input wire [3:0] note,      // Note to record
    input wire [7:0] octave,    // Octave to record
    output reg [3:0] playback_note,
    output reg [7:0] playback_octave
);

    localparam MAX_NOTES = 1000;
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

    // playback
    always @(posedge clk) begin
    if (playback) begin
        // index = 0 means we are starting playback
        if (playback_index == 0) begin
            playback_time <= 0; // Reset playback time
        end

        // Increment playback time by 1 every clock cycle (500hz)
        playback_time <= playback_time + 1;

        // Check if current playback time matches the timestamp for the next note
        if (playback_index < i && playback_time >= timestamp_log[playback_index]) begin // If it does
            playback_note <= note_log[playback_index];     // Play the note
            playback_octave <= octave_log[playback_index]; // and  octave

            playback_index <= playback_index + 1; // Move to the next note
        end
    end else begin
        playback_index <= 0; // else move back to the beginning of the recording
    end
end

endmodule
