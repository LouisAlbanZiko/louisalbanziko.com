const std = @import("std");
const server = @import("server");
const http = server.http;

const common = @import("/common.zig");
const db = @import("/demo/db.zig");

pub fn http_GET(ctx: *http.Context, _: *const http.Request, res: *http.Response) std.mem.Allocator.Error!void {
    res.code = ._200_OK;
    try ctx.template(res.body_writer(), @embedFile("index.html.template"), .{
        .global_css = common.global_css,
        .global_js = common.global_js,
    });
}

pub fn http_POST(ctx: *http.Context, req: *const http.Request, res: *http.Response) std.mem.Allocator.Error!void {
    const content_type = req.headers.get("Content-Type") orelse {
        res.code = ._400_BAD_REQUEST;
        _ = try res.write_body("Content-Type header not set.");
        return;
    };

    if (!std.mem.eql(u8, content_type, "application/x-www-form-urlencoded")) {
        res.code = ._400_BAD_REQUEST;
        try res.write_body_fmt("Content-Type set to the wrong value '{s}'. Only {s} is accepted.", .{ content_type, "application/x-www-form-urlencoded" });
        return;
    }

    const form_data = req.parse_body_form(ctx.arena) catch |err| switch (err) {
        error.OutOfMemory => {
            return error.OutOfMemory;
        },
        else => {
            res.code = ._400_BAD_REQUEST;
            try res.write_body_fmt("Failed to parse form data.", .{});
            return;
        },
    };

    const username = form_data.get("username") orelse {
        res.code = ._200_OK;
        try res.write_body_fmt("Username and Password not set.", .{});
        return;
    };

    const password1 = form_data.get("password1") orelse {
        res.code = ._200_OK;
        try res.write_body_fmt("Password not set", .{});
        return;
    };

    const password2 = form_data.get("password2") orelse {
        res.code = ._200_OK;
        try res.write_body_fmt("Please confirm passwords", .{});
        return;
    };

    if (!std.mem.eql(u8, password1, password2)) {
        res.code = ._200_OK;
        try res.write_body_fmt("Passwords do not match.", .{});
        return;
    }

    _ = db.new_profile(
        try ctx.arena.dupeZ(u8, username),
        try ctx.arena.dupeZ(u8, password1),
    ) catch |err| switch (err) {
        error.CONSTRAINT_UNIQUE => {
            res.code = ._200_OK;
            try res.write_body_fmt("Username already exists.", .{});
            return;
        },
        else => {
            res.code = ._200_OK;
            try res.write_body_fmt("Failed to create profile.", .{});
            return;
        },
    };

    res.code = ._200_OK;
    try res.header("HX-Redirect", "/demo/login");
}
