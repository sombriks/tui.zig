const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tui = b.addModule("tui", .{
        .root_source_file = b.path("src/tui.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addLibrary(.{
        .name = "tui",
        .linkage = .static,
        .root_module = tui,
    });
    b.installArtifact(lib);

    const unit_tests = b.addTest(.{
        .root_module = tui,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const examples = [_][]const u8{
        "counter",
        "demo",
        "image_render",
        "scroll_view",
        "split_view",
        "table",
        "text_input",
        "theme_switch",
    };

    const examples_step = b.step("examples", "Build all examples");

    for (examples) |example_name| {
        const example_module = b.createModule(.{
            .root_source_file = b.path(b.fmt("examples/{s}.zig", .{example_name})),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{ .name = "tui", .module = tui },
            },
        });

        const example_exe = b.addExecutable(.{
            .name = example_name,
            .root_module = example_module,
        });

        const install_example = b.addInstallArtifact(example_exe, .{});
        examples_step.dependOn(&install_example.step);

        const run_example = b.addRunArtifact(example_exe);
        run_example.step.dependOn(b.getInstallStep());
        // run_example.addPassthruArgs();

        const run_step = b.step(b.fmt("run-{s}", .{example_name}), b.fmt("Run the {s} example", .{example_name}));
        run_step.dependOn(&run_example.step);
    }
}
