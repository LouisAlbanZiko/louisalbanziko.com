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
    \\<link href="/css/tags" rel="stylesheet">
    \\<link href="/css/classes" rel="stylesheet">
    \\<link href="/css/common" rel="stylesheet">
    \\
;

pub const global_js: []const u8 =
    \\<script src="/js/htmx.min"></script>
    \\
;
