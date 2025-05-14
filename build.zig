const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cmark = b.addModule("cmark", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("cmark.zig"),
    });
    cmark.link_libc = true;
    cmark.addIncludePath(b.path("cmark/src"));
    cmark.addCSourceFiles(.{
        .language = .c,
        .files = &[_][]const u8{
            "cmark/src/blocks.c",
            "cmark/src/buffer.c",
            "cmark/src/cmark.c",
            "cmark/src/cmark_ctype.c",
            "cmark/src/houdini_href_e.c",
            "cmark/src/houdini_html_e.c",
            "cmark/src/houdini_html_u.c",
            "cmark/src/commonmark.c",
            "cmark/src/html.c",
            "cmark/src/inlines.c",
            "cmark/src/iterator.c",
            "cmark/src/latex.c",
            "cmark/src/node.c",
            "cmark/src/references.c",
            "cmark/src/render.c",
            "cmark/src/scanners.c",
            "cmark/src/utf8.c",
            "cmark/src/xml.c",
        },
    });

    const exe_name: []const u8 = "louisalbanziko.com";

    const hermes = b.dependency("hermes", .{
        .target = target,
        .optimize = optimize,
        .web_dir = b.path("www"),
        .mod_dir = b.path("mods"),
        .exe_name = exe_name,
    });

    const mod_cmark = hermes.module("/cmark.zig");
    mod_cmark.addImport("cmark", cmark);

    b.getInstallStep().dependOn(hermes.builder.getInstallStep());

    b.installFile("config.zon", "config.zon");

    const exe = hermes.artifact(exe_name);
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
