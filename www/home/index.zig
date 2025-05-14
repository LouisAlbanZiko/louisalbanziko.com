const std = @import("std");
const server = @import("server");
const http = server.http;

const common = @import("/common.zig");

pub fn http_GET(ctx: http.Context, _: *const http.Request) std.mem.Allocator.Error!http.Response {
    var body = std.ArrayList(u8).init(ctx.arena);
    try server.util.template(body.writer(), @embedFile("index.html.template"), .{
        .global_css = common.global_css,
        .theme = common.dark_theme,
        .global_js = common.global_js,
        .header = common.header,
    });
    return http.Response.file(ctx.arena, .@"text/html", try body.toOwnedSlice());
}
