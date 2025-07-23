const std = @import("std");
const rl = @import("raylib");
const main_mod = @import("main.zig");
const receptor_mod = @import("receptor.zig");
const note_mod = @import("note.zig");
const text_mod = @import("text.zig");

pub const FeedbackType = enum { GREAT, GOOD, MEH, BAD, MISS };

const Message = struct { feedback_type: FeedbackType, start_time: f32, font_size: f32, index: usize };

pub var miss_counter: i32 = 0;
pub var bad_counter: i32 = 0;
var messages: std.ArrayList(Message) = undefined;

pub fn loadMessages() void {
    messages = std.ArrayList(Message).init(main_mod.allocator);
}

pub fn unloadMessages() void {
    messages.deinit();
}

pub fn updateAndDrawMessages() void {
    for (messages.items, 0..) |*message, i| {
        if (rl.getTime() - message.start_time <= 0.2) {
            if (message.font_size >= 10) message.font_size -= main_mod.dt60;

            var text: [:0]const u8 = "";
            switch (message.feedback_type) {
                .GREAT => text = "GREAT!",
                .GOOD => text = "GOOD!",
                .MEH => text = "MEH",
                .BAD => text = "BAD",
                .MISS => text = "MISS",
            }
            text_mod.drawGlacialText(text, .{ .x = receptor_mod.receptors[message.index].rect.x + receptor_mod.def_receptor_size / 2 - text_mod.measureGlacialText(text, message.font_size, false).x / 2, .y = receptor_mod.receptors[message.index].rect.y - message.font_size - 20 }, message.font_size, .black, false);
        } else {
            _ = messages.orderedRemove(i);
            break;
        }
    }
}

pub fn signalFeedback(feedback_type: FeedbackType, index: usize) void {
    messages.append(.{ .feedback_type = feedback_type, .font_size = 32, .index = index, .start_time = @floatCast(rl.getTime()) }) catch {};
}
