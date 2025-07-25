const std = @import("std");
const rl = @import("raylib");
const main_mod = @import("main.zig");
const note_mod = @import("note.zig");
const feedback_mod = @import("feedback.zig");

pub var tutorial_level = [_]note_mod.NoteDataPair{
    .{ .beat = 8, .index = 0 },
    .{ .beat = 9, .index = 3 },
    .{ .beat = 10, .index = 0 },
    .{ .beat = 11, .index = 3 },
    .{ .beat = 12, .index = 2 },
    .{ .beat = 13, .index = 1 },
    .{ .beat = 14, .index = 2 },
    .{ .beat = 15, .index = 1 },
    .{ .beat = 16.5, .index = 0 },
    .{ .beat = 17, .index = 3 },
    .{ .beat = 18.5, .index = 2 },
    .{ .beat = 19, .index = 1 },
    .{ .beat = 20.5, .index = 0 },
    .{ .beat = 21, .index = 2 },
    .{ .beat = 22.5, .index = 3 },
    .{ .beat = 23, .index = 1 },
    .{ .beat = 24, .index = 1 },
    .{ .beat = 25, .index = 1 },
    .{ .beat = 26, .index = 1 },
    .{ .beat = 27, .index = 1 },
    .{ .beat = 28, .index = 1 },
    .{ .beat = 29, .index = 1 },
    .{ .beat = 30, .index = 1 },
    .{ .beat = 31, .index = 1 },
    .{ .beat = 31.5, .index = 1 },
};

var tutorial_level_song: rl.Music = undefined;
//const tutorial_level_bpm: f32 = 70;

pub fn loadLevels() void {
    tutorial_level_song = rl.loadMusicStream("res/sound/tutorial_level.mp3") catch |err| std.debug.panic("Crashed due to error: {}", .{err});

    // for some reason music goes out of sync, so we temporarily do this
    for (&tutorial_level) |*noteDataPair| {
        noteDataPair.beat -= 0.25;
    }
}

pub fn unloadLevels() void {
    rl.unloadMusicStream(tutorial_level_song);
}

pub fn updateLevels() void {
    rl.updateMusicStream(tutorial_level_song);
}

pub fn startLevel() void {
    main_mod.gamestate = .PLAYING;
    //main_mod.bpm = tutorial_level_bpm;

    note_mod.level.clearRetainingCapacity();
    note_mod.notes.clearRetainingCapacity();
    for (tutorial_level) |noteDataPair| {
        note_mod.level.append(noteDataPair) catch {};
    }

    main_mod.current_beat = 0;
    main_mod.score = 0;

    feedback_mod.miss_counter = 0;
    feedback_mod.bad_counter = 0;

    if (rl.isMusicStreamPlaying(tutorial_level_song)) rl.stopMusicStream(tutorial_level_song);
    rl.playMusicStream(tutorial_level_song);
}
