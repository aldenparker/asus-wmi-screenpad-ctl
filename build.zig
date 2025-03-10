const std = @import("std");

pub fn build(b: *std.Build) void {
    // Setup exe
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "asus-wmi-screenpad-ctl",
        .root_module = exe_mod,
    });

    // Include known_folders library
    const known_folders = b.dependency("known_folders", .{}).module("known-folders");
    exe.root_module.addImport("known-folders", known_folders);

    // Install
    b.installArtifact(exe);

    // Setup run command ie. `zig build run -- arg1 arg2 etc`
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Add unit tests
    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
