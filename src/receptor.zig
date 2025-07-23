const std = @import("std");
const rl = @import("raylib");
const main_mod = @import("main.zig");
const note_mod = @import("note.zig");
const feedback_mod = @import("feedback.zig");

pub const def_receptor_size: f32 = 80;
pub const def_receptor_ypos: f32 = main_mod.screenHeight - def_receptor_size - 20;
var receptor_texture_atlas: rl.Texture2D = undefined;

pub const space: f32 = 20;
pub const receptor_with_space: f32 = def_receptor_size + space;

const Receptor = struct {
    index: usize,
    size: f32,
    rect: rl.Rectangle,

    fn update(self: *Receptor) void {
        if (self.size > def_receptor_size) self.size -= main_mod.dt60 * 3;
        self.rect = rl.Rectangle{ .x = (main_mod.screenWidth - (3 * receptor_with_space + self.size)) / 2 + (@as(f32, @floatFromInt(self.index)) * receptor_with_space), .y = main_mod.screenHeight - self.size - 20, .width = self.size, .height = self.size };
    }

    fn draw(self: *Receptor) void {
        rl.drawTexturePro(receptor_texture_atlas, rl.Rectangle{ .x = @floatFromInt(self.index * 16), .y = 0, .width = 16, .height = 16 }, self.rect, rl.Vector2.zero(), 0, rl.Color.white);
    }
};

pub var receptors: [4]Receptor = undefined;

pub fn loadReceptors() void {
    receptor_texture_atlas = rl.loadTexture("res/receptor-atlas.png") catch |err| std.debug.panic("Crashed due to error: {}", .{err});
}

pub fn unloadReceptors() void {
    rl.unloadTexture(receptor_texture_atlas);
}

pub fn initReceptors() void {
    for (0..receptors.len) |index| {
        receptors[index] = Receptor{ .index = index, .size = def_receptor_size, .rect = rl.Rectangle{ .x = (main_mod.screenWidth - (3 * receptor_with_space + def_receptor_size)) / 2 + (@as(f32, @floatFromInt(index)) * receptor_with_space), .y = def_receptor_ypos, .width = def_receptor_size, .height = def_receptor_size } };
    }
}

pub fn updateReceptors() void {
    for (0..receptors.len) |index| {
        receptors[index].update();
    }

    if (rl.isKeyPressed(.d)) hitReceptor(&receptors[0]);
    if (rl.isKeyPressed(.f)) hitReceptor(&receptors[1]);
    if (rl.isKeyPressed(.j)) hitReceptor(&receptors[2]);
    if (rl.isKeyPressed(.k)) hitReceptor(&receptors[3]);
}

pub fn drawReceptors() void {
    for (0..receptors.len) |index| {
        receptors[index].draw();
    }
}

fn hitReceptor(receptor: *Receptor) void {
    if (note_mod.notes.items.len > 0) {
        for (0..note_mod.notes.items.len) |i| {
            const note = note_mod.notes.items[i];
            const time_diff = rl.getTime() - note.scheduled_hit_time;
            if (note.index == receptor.index and time_diff >= -0.35 and time_diff <= 0.35) {
                if (time_diff >= -0.03 and time_diff <= 0.03) {
                    feedback_mod.signalFeedback(.GREAT, receptor.index);
                    main_mod.score += 50;
                    if (feedback_mod.bad_counter != 0) feedback_mod.bad_counter = 0;
                } else if (time_diff >= -0.1 and time_diff <= 0.1) {
                    feedback_mod.signalFeedback(.GOOD, receptor.index);
                    main_mod.score += 30;
                    if (feedback_mod.bad_counter != 0) feedback_mod.bad_counter = 0;
                } else if (time_diff >= -0.17 and time_diff <= 0.17) {
                    feedback_mod.signalFeedback(.MEH, receptor.index);
                    main_mod.score += 15;
                    if (feedback_mod.bad_counter != 0) feedback_mod.bad_counter = 0;
                } else {
                    feedback_mod.signalFeedback(.BAD, receptor.index);
                    main_mod.score += 5;
                    feedback_mod.bad_counter += 1;
                }

                if (feedback_mod.miss_counter != 0) feedback_mod.miss_counter = 0;
                _ = note_mod.notes.orderedRemove(i);
                break;
            }
        }
    }

    receptor.size = 100;
}
