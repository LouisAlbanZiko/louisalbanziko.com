const std = @import("std");
const server = @import("server");
const http = server.http;

const common = @import("/common.zig");

pub fn http_GET(ctx: *http.Context, _: *const http.Request, res: *http.Response) std.mem.Allocator.Error!void {
    res.code = ._200_OK;
    try ctx.template(res.body_writer(), @embedFile("index.html.template"), .{
        .global_css = common.global_css,
        .global_js = common.global_js,
    });
}

