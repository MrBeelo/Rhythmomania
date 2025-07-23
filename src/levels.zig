const std = @import("std");
const rl = @import("raylib");
const main_mod = @import("main.zig");
const note_mod = @import("note.zig");

pub const level1 = [_]note_mod.NoteDataPair{
    .{ .beat = 1, .index = 0 },
    .{ .beat = 1, .index = 1 },
    .{ .beat = 3, .index = 2 },
    .{ .beat = 4, .index = 3 },
    .{ .beat = 5, .index = 2 },
    .{ .beat = 6, .index = 1 },
    .{ .beat = 7, .index = 0 },
    .{ .beat = 8, .index = 1 },
    .{ .beat = 9, .index = 2 },
    .{ .beat = 10, .index = 3 },
    .{ .beat = 11, .index = 2 },
    .{ .beat = 11.5, .index = 1 },
    .{ .beat = 13, .index = 0 },
    .{ .beat = 14, .index = 1 },
    .{ .beat = 15, .index = 2 },
    .{ .beat = 16, .index = 3 },
    .{ .beat = 17, .index = 2 },
    .{ .beat = 18, .index = 1 },
    .{ .beat = 19, .index = 0 },
    .{ .beat = 20, .index = 1 },
};

pub fn startLevel() void {
    main_mod.gamestate = .PLAYING;

    note_mod.level.clearRetainingCapacity();
    for (level1) |noteDataPair| {
        note_mod.level.append(noteDataPair) catch {};
    }

    main_mod.current_beat = 0;
    main_mod.score = 0;
}

pub fn loseLevel() void {
    main_mod.gamestate = .DEAD;
    main_mod.score = 0;
}
