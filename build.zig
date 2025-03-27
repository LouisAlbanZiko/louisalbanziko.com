const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const http_server = b.dependency("http_server", .{
        .target = target,
        .optimize = optimize,
        .web_dir = b.path("www"),
    });

    b.getInstallStep().dependOn(http_server.builder.getInstallStep());

    b.installFile("config.zon", "config.zon");

    const exe = http_server.artifact("server_exe");
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
