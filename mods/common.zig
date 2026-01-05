const std = @import("std");
const server = @import("server");
const http = server.http;

pub const header: []const u8 =
    \\<pe-header>
    \\  <a href="/home">About me</a>
    \\  <a href="/projects">Projects</a>
    \\</pe-header>
    \\
;

pub const global_css: []const u8 =
    \\<link href="/css/tags.css" rel="stylesheet">
    \\<link href="/css/classes.css" rel="stylesheet">
    \\<link href="/css/common.css" rel="stylesheet">
    \\<link href="/css/themes.css" rel="stylesheet">
    \\<link rel="icon" href="/favicon.svg" type="image/svg+xml">
    \\
;

pub const global_js: []const u8 =
    \\<script src="/js/htmx.min.js"></script>
    \\
;

