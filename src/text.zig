const std = @import("std");
const rl = @import("raylib");
const main_mod = @import("main.zig");

pub var glacial: rl.Font = undefined;
pub var glacial_bold: rl.Font = undefined;

pub fn loadGlacial() void {
    glacial = rl.loadFontEx("res/glacial.otf", 100, null) catch |err| std.debug.panic("Crashed due to error: {}", .{err});
    glacial_bold = rl.loadFontEx("res/glacial-bold.otf", 100, null) catch |err| std.debug.panic("Crashed due to error: {}", .{err});
}

pub fn unloadGlacial() void {
    rl.unloadFont(glacial);
    rl.unloadFont(glacial_bold);
}

pub fn drawGlacialText(text: [:0]const u8, position: rl.Vector2, font_size: f32, tint: rl.Color, bold: bool) void {
    rl.drawTextEx(if (bold) glacial_bold else glacial, text, position, font_size, 0, tint);
}

pub fn drawGlacialTextPro(text: [:0]const u8, position: rl.Vector2, origin: rl.Vector2, rotation: f32, font_size: f32, spacing: f32, tint: rl.Color, bold: bool) void {
    rl.drawTextPro(if (bold) glacial_bold else glacial, text, position, origin, rotation, font_size, spacing, tint);
}

pub fn measureGlacialText(text: [:0]const u8, font_size: f32, bold: bool) rl.Vector2 {
    return rl.measureTextEx(if (bold) glacial_bold else glacial, text, font_size, 0);
}

pub fn measureGlacialTextPro(text: [:0]const u8, font_size: f32, spacing: f32, bold: bool) rl.Vector2 {
    return rl.measureTextEx(if (bold) glacial_bold else glacial, text, font_size, spacing);
}
