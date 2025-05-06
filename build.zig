const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_name: []const u8 = "louisalbanziko.com";

    const hermes = b.dependency("hermes", .{
        .target = target,
        .optimize = optimize,
        .web_dir = b.path("www"),
        .mod_dir = b.path("mods"),
        .exe_name = exe_name,
    });

    b.getInstallStep().dependOn(hermes.builder.getInstallStep());

    b.installFile("config.zon", "config.zon");

    const exe = hermes.artifact(exe_name);
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
