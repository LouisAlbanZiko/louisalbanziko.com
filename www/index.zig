const std = @import("std");
const server = @import("server");
const http = server.http;

const common = @import("/common.zig");

pub fn http_GET(_: *http.Context, _: *const http.Request, res: *http.Response) std.mem.Allocator.Error!void {
    res.code = ._302_FOUND;
    try res.header("Location", "/home");
}
