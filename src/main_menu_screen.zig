const std = @import("std");
const rl = @import("raylib");
const receptor_mod = @import("receptor.zig");
const note_mod = @import("note.zig");
const text_mod = @import("text.zig");
const main_mod = @import("main.zig");
const levels_mod = @import("levels.zig");

pub fn updateMainMenuScreen() void {
    if (rl.isKeyPressed(.space)) levels_mod.startLevel();
}

pub fn drawMainMenuScreen() void {
    const title_text = "RHYTHMOMANIA";
    const title_text_font_size: f32 = 64;
    text_mod.drawGlacialText(title_text, .{ .x = main_mod.screenWidth / 2 - text_mod.measureGlacialText(title_text, title_text_font_size, true).x / 2, .y = 100 }, title_text_font_size, .black, true);

    const play_text = "Press space to play!";
    const play_text_font_size: f32 = 32;
    text_mod.drawGlacialText(play_text, .{ .x = main_mod.screenWidth / 2 - text_mod.measureGlacialText(play_text, play_text_font_size, false).x / 2, .y = 300 }, play_text_font_size, .black, false);
}
