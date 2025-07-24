const std = @import("std");
const rl = @import("raylib");
const receptor_mod = @import("receptor.zig");
const note_mod = @import("note.zig");
const text_mod = @import("text.zig");
const feedback_mod = @import("feedback.zig");
const main_menu_screen_mod = @import("main_menu_screen.zig");
const death_screen_mod = @import("death_screen.zig");
const win_screen_mod = @import("win_screen.zig");

pub const allocator = std.heap.page_allocator;

pub const screenWidth = 800;
pub const screenHeight = 450;

pub var dt60: f32 = 0;

pub var current_beat: f32 = 0;
pub const bpm: f32 = 120;
pub const delay_time: f32 = 60 / bpm;

pub var score: f32 = 0;

pub const Gamestate = enum { PLAYING, MAIN_MENU, DEAD, WON };

pub var gamestate: Gamestate = .MAIN_MENU;

pub fn main() void {
    rl.initWindow(screenWidth, screenHeight, "Rhythmomania");
    defer rl.closeWindow();

    rl.setExitKey(.null);

    text_mod.loadGlacial();
    defer text_mod.unloadGlacial();

    feedback_mod.loadMessages();
    defer feedback_mod.unloadMessages();

    receptor_mod.loadReceptors();
    defer receptor_mod.unloadReceptors();

    note_mod.loadNotes();
    defer note_mod.unloadNotes();

    receptor_mod.initReceptors();

    while (!rl.windowShouldClose()) {
        dt60 = rl.getFrameTime() * 60;

        switch (gamestate) {
            .PLAYING => {
                receptor_mod.updateReceptors();
                note_mod.updateNotes();
            },
            .MAIN_MENU => {
                main_menu_screen_mod.updateMainMenuScreen();
            },
            .DEAD => {
                death_screen_mod.updateDeathScreen();
            },
            .WON => {
                win_screen_mod.updateWinScreen();
            },
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        switch (gamestate) {
            .PLAYING => {
                receptor_mod.drawReceptors();
                note_mod.drawNotes();
                feedback_mod.updateAndDrawMessages();

                text_mod.drawGlacialText(std.fmt.allocPrintZ(allocator, "SCORE: {d:.0}", .{score}) catch "", .{ .x = 10, .y = 10 }, 48, .black, true);
            },
            .MAIN_MENU => {
                main_menu_screen_mod.drawMainMenuScreen();
            },
            .DEAD => {
                death_screen_mod.drawDeathScreen();
            },
            .WON => {
                win_screen_mod.drawWinScreen();
            },
        }
    }
}
