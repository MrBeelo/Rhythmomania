const std = @import("std");
const rl = @import("raylib");
const main_mod = @import("main.zig");
const receptor_mod = @import("receptor.zig");
const timer_mod = @import("timer.zig");
const levels_mod = @import("levels.zig");
const feedback_mod = @import("feedback.zig");

var note_texture_atlas: rl.Texture2D = undefined;

var note_spawn_timer: timer_mod.Timer = undefined;

pub const spawn_ypos: f32 = -receptor_mod.def_receptor_size;
pub const note_speed: f32 = ((receptor_mod.def_receptor_ypos - spawn_ypos) / main_mod.delay_time) / 60;

pub const Note = struct {
    index: usize,
    ypos: f32,
    rect: rl.Rectangle,
    scheduled_hit_time: f32,

    fn update(self: *Note, i: usize) void {
        self.ypos += note_speed * main_mod.dt60;
        self.rect = rl.Rectangle{ .x = (main_mod.screenWidth - (3 * receptor_mod.receptor_with_space + receptor_mod.def_receptor_size)) / 2 +
            (@as(f32, @floatFromInt(self.index)) * receptor_mod.receptor_with_space), .y = self.ypos, .width = receptor_mod.def_receptor_size, .height = receptor_mod.def_receptor_size };
        if (self.ypos > main_mod.screenHeight + 100) {
            feedback_mod.signalFeedback(.MISS, self.index);
            feedback_mod.miss_counter += 1;
            _ = notes.orderedRemove(i);
        }
    }

    fn draw(self: *Note) void {
        rl.drawTexturePro(note_texture_atlas, rl.Rectangle{ .x = @floatFromInt(self.index * 16), .y = 0, .width = 16, .height = 16 }, self.rect, rl.Vector2.zero(), 0, rl.Color.white);
    }
};

pub const NoteDataPair = struct {
    beat: f32,
    index: usize,
};

pub var level: std.ArrayList(NoteDataPair) = undefined;
pub var notes: std.ArrayList(Note) = undefined;

pub fn loadNotes() void {
    note_texture_atlas = rl.loadTexture("res/sprite/note-atlas.png") catch |err| std.debug.panic("Crashed due to error: {}", .{err});
    notes = std.ArrayList(Note).init(main_mod.allocator);
    level = std.ArrayList(NoteDataPair).init(main_mod.allocator);

    note_spawn_timer = timer_mod.Timer{ .duration = 60 / main_mod.bpm * 0.25, .repeat = true, .auto_start = true };
    note_spawn_timer.init();
}

pub fn unloadNotes() void {
    rl.unloadTexture(note_texture_atlas);
    if (notes.items.len > 0) notes.deinit();
    if (level.items.len > 0) level.deinit();
}

pub fn summonNote(index: usize) void {
    notes.append(Note{ .index = index, .ypos = spawn_ypos, .rect = rl.Rectangle{ .x = (main_mod.screenWidth - (3 * receptor_mod.receptor_with_space + receptor_mod.def_receptor_size)) / 2 +
        (@as(f32, @floatFromInt(index)) * receptor_mod.receptor_with_space), .y = spawn_ypos, .width = receptor_mod.def_receptor_size, .height = receptor_mod.def_receptor_size }, .scheduled_hit_time = @floatCast(rl.getTime() + main_mod.delay_time) }) catch {};
}

pub fn updateNotes() void {
    for (notes.items, 0..) |*note, i| {
        note.update(i);
    }

    note_spawn_timer.update();
    if (note_spawn_timer.call) {
        main_mod.current_beat += 0.25;

        while (level.items.len > 0 and level.items[0].beat == main_mod.current_beat) {
            summonNote(level.items[0].index);
            _ = level.orderedRemove(0);
        }

        if (level.items.len == 0 and notes.items.len == 0) main_mod.gamestate = .WON;
    }

    if (feedback_mod.miss_counter >= 3 or feedback_mod.bad_counter >= 5) main_mod.gamestate = .DEAD;
}

pub fn drawNotes() void {
    for (notes.items) |*note| {
        note.draw();
    }
    rl.drawText(std.fmt.allocPrintZ(main_mod.allocator, "BEAT: {d}", .{main_mod.current_beat}) catch "", 10, 50, 32, .black);
}
