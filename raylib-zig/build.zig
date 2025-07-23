// raylib-zig (c) Nikolas Wipper 2020-2024

const std = @import("std");
const this = @This();
const rl = @import("raylib");

pub const emcc = @import("emcc.zig");

pub const Options = rl.Options;
pub const OpenglVersion = rl.OpenglVersion;
pub const LinuxDisplayBackend = rl.LinuxDisplayBackend;
pub const PlatformBackend = rl.PlatformBackend;

const Program = struct {
    name: []const u8,
    path: []const u8,
    desc: []const u8,
};

fn getRaylib(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, options: Options) *std.Build.Step.Compile {
    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
        .raudio = options.raudio,
        .rmodels = options.rmodels,
        .rshapes = options.rshapes,
        .rtext = options.rtext,
        .rtextures = options.rtextures,
        .platform = options.platform,
        .shared = options.shared,
        .linux_display_backend = options.linux_display_backend,
        .opengl_version = options.opengl_version,
        .android_api_version = options.android_api_version,
        .android_ndk = options.android_ndk
    });

    const raylib = raylib_dep.artifact("raylib");

    const raygui_dep = b.dependency("raygui", .{
        .target = target,
        .optimize = optimize,
    });

    rl.addRaygui(b, raylib, raygui_dep, options);

    b.installArtifact(raylib);
    return raylib;
}

fn getModule(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Module {
    if (b.modules.contains("raylib")) {
        return b.modules.get("raylib").?;
    }
    return b.addModule("raylib", .{
        .root_source_file = b.path("lib/raylib.zig"),
        .target = target,
        .optimize = optimize,
    });
}

const gui = struct {
    fn getModule(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Module {
        const raylib = this.getModule(b, target, optimize);
        return b.addModule("raygui", .{
            .root_source_file = b.path("lib/raygui.zig"),
            .imports = &.{.{ .name = "raylib-zig", .module = raylib }},
            .target = target,
            .optimize = optimize,
        });
    }
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_artifact = this.getRaylib(b, target, optimize, Options.getOptions(b));
    const raylib = this.getModule(b, target, optimize);
    const raygui = this.gui.getModule(b, target, optimize);

    const examples = [_]Program{
        .{
            .name = "raw_stream",
            .path = "examples/audio/raw_stream.zig",
            .desc = "Plays a sine wave",
        },
        .{
            .name = "music_stream",
            .path = "examples/audio/music_stream.zig",
            .desc = "Use music stream to play an audio file",
        },
        .{
            .name = "sound_loading",
            .path = "examples/audio/sound_loading.zig",
            .desc = "Load and play a song",
        },
        .{
            .name = "module_playing",
            .path = "examples/audio/module_playing.zig",
            .desc = "Module playing (streaming)",
        },
        .{
            .name = "basic_screen_manager",
            .path = "examples/core/basic_screen_manager.zig",
            .desc = "Illustrates simple screen manager based on a state machine",
        },
        .{
            .name = "basic_window",
            .path = "examples/core/basic_window.zig",
            .desc = "Creates a basic window with text",
        },
        .{
            .name = "basic_window_web",
            .path = "examples/core/basic_window_web.zig",
            .desc = "Creates a basic window with text (web)",
        },
        .{
            .name = "input_keys",
            .path = "examples/core/input_keys.zig",
            .desc = "Simple keyboard input",
        },
        .{
            .name = "input_mouse",
            .path = "examples/core/input_mouse.zig",
            .desc = "Simple mouse input",
        },
        .{
            .name = "input_mouse_wheel",
            .path = "examples/core/input_mouse_wheel.zig",
            .desc = "Mouse wheel input",
        },
        .{
            .name = "input_multitouch",
            .path = "examples/core/input_multitouch.zig",
            .desc = "Multitouch input",
        },
        .{
            .name = "2d_camera",
            .path = "examples/core/2d_camera.zig",
            .desc = "Shows the functionality of a 2D camera",
        },
        .{
            .name = "2d_camera_platformer",
            .path = "examples/core/2d_camera_platformer.zig",
            .desc = "2D camera platformer",
        },
        .{
            .name = "3d_camera_first_person",
            .path = "examples/core/3d_camera_first_person.zig",
            .desc = "Simple first person demo",
        },
        .{
            .name = "3d_camera_free",
            .path = "examples/core/3d_camera_free.zig",
            .desc = "Shows basic 3d camera initialization",
        },
        .{
            .name = "2d_camera_mouse_zoom",
            .path = "examples/core/2d_camera_mouse_zoom.zig",
            .desc = "Shows mouse zoom demo",
        },
        .{
            .name = "3d_picking",
            .path = "examples/core/3d_picking.zig",
            .desc = "Shows picking in 3d mode",
        },
        .{
            .name = "window_flags",
            .path = "examples/core/window_flags.zig",
            .desc = "Demonstrates various flags used during and after window creation",
        },
        .{
            .name = "gui_message_box",
            .path = "examples/gui/message_box.zig",
            .desc = "Demonstrates showing and hiding a message box",
        },
        .{
            .name = "raymarching",
            .path = "examples/shaders/raymarching.zig",
            .desc = "Uses a raymarching in a shader to render shapes",
        },
        .{
            .name = "texture_outline",
            .path = "examples/shaders/texture_outline.zig",
            .desc = "Uses a shader to create an outline around a sprite",
        },
        .{
            .name = "logo_raylib",
            .path = "examples/shapes/logo_raylib.zig",
            .desc = "Renders the raylib-zig logo",
        },
        .{
            .name = "logo_raylib_anim",
            .path = "examples/shapes/logo_raylib_anim.zig",
            .desc = "Animates the raylib logo",
        },
        .{
            .name = "basic_shapes",
            .path = "examples/shapes/basic_shapes.zig",
            .desc = "Renders various shapes",
        },
        .{
            .name = "bouncing_ball",
            .path = "examples/shapes/bouncing_ball.zig",
            .desc = "Bouncing ball animation with collision detection",
        },
        .{
            .name = "collision_area",
            .path = "examples/shapes/collision_area.zig",
            .desc = "Demonstrates collision detection",
        },
        .{
            .name = "colors_palette",
            .path = "examples/shapes/colors_palette.zig",
            .desc = "Renders an interactive color palette",
        },
        .{
            .name = "draw_circle_sector",
            .path = "examples/shapes/draw_circle_sector.zig",
            .desc = "Dynamically renders a circle sector using raygui",
        },
        .{
            .name = "draw_rectangle_rounded",
            .path = "examples/shapes/draw_rectangle_rounded.zig",
            .desc = "Dynamically renders a rounded rectangle using raygui",
        },
        .{
            .name = "draw_ring",
            .path = "examples/shapes/draw_ring.zig",
            .desc = "Dynaically renders a ring using raygui",
        },
        .{
            .name = "following_eyes",
            .path = "examples/shapes/following_eyes.zig",
            .desc = "Renders eyes that follow mouse movement",
        },
        .{
            .name = "lines_bezier",
            .path = "examples/shapes/lines_bezier.zig",
            .desc = "Renders an interactive line bezier",
        },
        .{
            .name = "rectangle_scaling",
            .path = "examples/shapes/rectangle_scaling.zig",
            .desc = "Renders a resizable rectangle",
        },
        .{
            .name = "sprite_anim",
            .path = "examples/textures/sprite_anim.zig",
            .desc = "Animate a sprite",
        },
        .{
            .name = "textures_background_scrolling",
            .path = "examples/textures/textures_background_scrolling.zig",
            .desc = "Background scrolling & parallax demo",
        },
        .{
            .name = "text_format_text",
            .path = "examples/text/text_format_text.zig",
            .desc = "Renders variables as text",
        },
        .{
            .name = "text_raylib_fonts",
            .path = "examples/text/text_raylib_fonts.zig",
            .desc = "Show fonts included with raylib",
        },
        .{
            .name = "text_writing_anim",
            .path = "examples/text/text_writing_anim.zig",
            .desc = "Simple text animation",
        },
        .{
            .name = "textures_image_loading",
            .path = "examples/textures/textures_image_loading.zig",
            .desc = "Image loading and texture creation",
        },

        .{
            .name = "models_heightmap",
            .path = "examples/models/models_heightmap.zig",
            .desc = "Heightmap loading and drawing",
        },
        // .{
        //     .name = "shaders_basic_lighting",
        //     .path = "examples/shaders/shaders_basic_lighting.zig",
        //     .desc = "Loads a model and renders it",
        // },
    };

    const raylib_test = b.addTest(.{
        .root_source_file = b.path("lib/raylib.zig"),
        .target = target,
        .optimize = optimize,
    });
    raylib_test.linkLibC();

    const raygui_test = b.addTest(.{
        .root_source_file = b.path("lib/raygui.zig"),
        .target = target,
        .optimize = optimize,
    });
    raygui_test.root_module.addImport("raylib-zig", raylib);
    raygui_test.linkLibC();

    const test_step = b.step("test", "Check for library compilation errors");
    test_step.dependOn(&raylib_test.step);
    test_step.dependOn(&raygui_test.step);

    const examples_step = b.step("examples", "Builds all the examples");

    for (examples) |ex| {
        if (target.query.os_tag == .emscripten) {
            const exe_lib = try emcc.compileForEmscripten(b, ex.name, ex.path, target, optimize);
            exe_lib.root_module.addImport("raylib", raylib);
            exe_lib.root_module.addImport("raygui", raygui);

            // Note that raylib itself isn't actually added to the exe_lib
            // output file, so it also needs to be linked with emscripten.
            exe_lib.linkLibrary(raylib_artifact);
            const link_step = try emcc.linkWithEmscripten(b, &[_]*std.Build.Step.Compile{ exe_lib, raylib_artifact });
            link_step.addArg("--emrun");
            link_step.addArg("--embed-file");
            link_step.addArg("resources/");

            const run_step = try emcc.emscriptenRunStep(b);
            run_step.step.dependOn(&link_step.step);
            const run_option = b.step(ex.name, ex.desc);

            run_option.dependOn(&run_step.step);
            examples_step.dependOn(&exe_lib.step);
        } else {
            const exe = b.addExecutable(.{
                .name = ex.name,
                .root_source_file = b.path(ex.path),
                .optimize = optimize,
                .target = target,
            });
            exe.linkLibrary(raylib_artifact);
            exe.root_module.addImport("raylib", raylib);
            exe.root_module.addImport("raygui", raygui);

            const run_cmd = b.addRunArtifact(exe);
            const run_step = b.step(ex.name, ex.desc);

            run_step.dependOn(&run_cmd.step);
            examples_step.dependOn(&exe.step);
        }
    }
}
