const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cmark = b.dependency("cmark", .{
        .target = target,
        .optimize = optimize,
    });
    const cmark_mod = cmark.module("cmark");

    const exe_name: []const u8 = "louisalbanziko.com";

    const hermes = b.dependency("hermes", .{
        .target = target,
        .optimize = optimize,
        .web_dir = b.path("www"),
        .mod_dir = b.path("mods"),
        .exe_name = exe_name,
    });

    const mod_cmark = hermes.module("/cmark.zig");
    mod_cmark.addImport("cmark", cmark_mod);

    b.getInstallStep().dependOn(hermes.builder.getInstallStep());

    b.installFile("config.zon", "config.zon");

    const exe = hermes.artifact(exe_name);
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
