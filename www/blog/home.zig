const std = @import("std");
const server = @import("server");
const http = server.http;

const common = @import("/common.zig");

pub fn http_GET(ctx: http.Context, _: *const http.Request) std.mem.Allocator.Error!http.Response {
    const articles = ctx.resources.lookup("blog/md").?.value.directory;

    var content = std.ArrayList(u8).init(ctx.arena);
    for (articles.resources) |res| {
        const title = try ctx.arena.dupe(u8, res.path[0 .. res.path.len - 3]);
        std.mem.replaceScalar(u8, title, '_', ' ');
        try std.fmt.format(content.writer(), "<li><a href=\"./article?name={s}\">{s}</a></li>", .{ res.path, title });
    }

    var body = std.ArrayList(u8).init(ctx.arena);
    try server.util.template(body.writer(), @embedFile("home.html.template"), .{
        .global_css = common.global_css,
        .theme = common.dark_theme,
        .global_js = common.global_js,
        .header = common.header,
        .content = try content.toOwnedSlice(),
    });
    return http.Response.file(ctx.arena, .@"text/html", try body.toOwnedSlice());
}
