const std = @import("std");
const server = @import("server");
const http = server.http;

pub const header: []const u8 =
    \\<pe-header>
    \\  <a href="/home">Home</a>
    \\</pe-header>
    \\
;

pub const global_css: []const u8 =
    \\<link href="/css/tags.css" rel="stylesheet">
    \\<link href="/css/classes.css" rel="stylesheet">
    \\<link href="/css/common.css" rel="stylesheet">
    \\
;

pub const global_js: []const u8 =
    \\<script src="/js/htmx.min.js"></script>
    \\
;

pub const dark_theme: []const u8 =
    \\<link href="/css/themes/dark.css" rel="stylesheet">
;
