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
            .body = "Content-Type header not set.",
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

    const password = form_data.get("password") orelse {
        return http.Response{
            .code = .@"200 Ok",
            .headers = &[_]http.Header{},
            .body = "Password not set.",
        };
    };

    const has_user = db.check_login(
        try ctx.arena().dupeZ(u8, username),
        try ctx.arena().dupeZ(u8, password),
    ) catch {
        return http.Response{
            .code = .@"200 Ok",
            .headers = &[_]http.Header{},
            .body = "Unexpected Error Occured while checking login.",
        };
    };

    if (has_user) |_| {
        var headers = std.ArrayList(http.Header).init(ctx.arena());
        try headers.append(.{ "HX-Redirect", "/demo/home" });

        return http.Response{
            .code = .@"200 Ok",
            .headers = try headers.toOwnedSlice(),
            .body = "Unexpected Error Occured while checking login.",
        };
    } else {
        return http.Response{
            .code = .@"200 Ok",
            .headers = &[_]http.Header{},
            .body = "Username and password do not match a known profile.",
        };
    }
}
