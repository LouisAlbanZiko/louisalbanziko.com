const std = @import("std");
const server = @import("server");
const http = server.http;

const common = @import("/common.zig");

pub fn http_GET(arena: std.mem.Allocator, _: *const http.Request) std.mem.Allocator.Error!http.Response {
    return http.Response.redirect(arena, "/home");
}
