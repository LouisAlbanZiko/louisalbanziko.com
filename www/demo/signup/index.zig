const std = @import("std");
const server = @import("server");
const http = server.http;

const common = @import("/common.zig");
const db = @import("/demo/db.zig");

pub fn http_GET(ctx: *http.Context, _: *const http.Request) std.mem.Allocator.Error!http.Response {
    var body = std.ArrayList(u8).init(ctx.arena());
    try ctx.template(body.writer(), @embedFile("index.html.template"), .{
        .global_css = common.global_css,
        .global_js = common.global_js,
        .theme = common.dark_theme,
    });
    return try http.Response.file(ctx.arena(), .@"text/html", try body.toOwnedSlice());
}

pub fn http_POST(ctx: *http.Context, req: *const http.Request) std.mem.Allocator.Error!http.Response {
    const content_type = req.@"Content-Type" orelse {
        return http.Response{
            .code = .@"400 Bad Request",
            .headers = &[_]http.Header{},
            .body = "Content-Type not found.",
        };
    };

    if (content_type != .@"application/x-www-form-urlencoded") {
        return http.Response{
            .code = .@"400 Bad Request",
            .headers = &[_]http.Header{},
            .body = "Content-Type not accepted.",
        };
    }

    const form_data = req.parse_body_form(ctx.arena()) catch |err| switch (err) {
        error.OutOfMemory => {
            return error.OutOfMemory;
        },
        else => {
            return http.Response{
                .code = .@"400 Bad Request",
                .headers = &[_]http.Header{},
                .body = "Failed to parse form data.",
            };
        },
    };

    const username = form_data.get("username") orelse {
        return http.Response{
            .code = .@"200 Ok",
            .headers = &[_]http.Header{},
            .body = "Username and Password not set.",
        };
    };

    const password1 = form_data.get("password1") orelse {
        return http.Response{
            .code = .@"200 Ok",
            .headers = &[_]http.Header{},
            .body = "Password not set.",
        };
    };

    const password2 = form_data.get("password2") orelse {
        return http.Response{
            .code = .@"200 Ok",
            .headers = &[_]http.Header{},
            .body = "Please confirm password.",
        };
    };

    if (!std.mem.eql(u8, password1, password2)) {
        return http.Response{
            .code = .@"200 Ok",
            .headers = &[_]http.Header{},
            .body = "Passwords do not match.",
        };
    }

    _ = db.new_profile(
        try ctx.arena().dupeZ(u8, username),
        try ctx.arena().dupeZ(u8, password1),
    ) catch |err| switch (err) {
        error.CONSTRAINT_UNIQUE => {
            return http.Response{
                .code = .@"200 Ok",
                .headers = &[_]http.Header{},
                .body = "Username already exists.",
            };
        },
        else => {
            return http.Response{
                .code = .@"200 Ok",
                .headers = &[_]http.Header{},
                .body = "Failed to create profile.",
            };
        },
    };

    var headers = std.ArrayList(http.Header).init(ctx.arena());
    try headers.append(.{ "HX-Redirect", "/demo/login" });

    return http.Response{
        .code = .@"200 Ok",
        .headers = try headers.toOwnedSlice(),
        .body = "",
    };
}
