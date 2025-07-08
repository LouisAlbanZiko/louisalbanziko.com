const std = @import("std");
const server = @import("server");
const http = server.http;

const cmark = @import("/cmark.zig");
const common = @import("/common.zig");

const Article = struct {
    title: []const u8,
    content: [:0]const u8,
};

pub fn http_GET(ctx: http.Context, req: *const http.Request) std.mem.Allocator.Error!http.Response {
    const name = req.query.get("name") orelse {
        return http.Response.redirect(ctx.arena, "/blog");
    };

    const articles = ctx.resources.lookup("blog/md").?.value.directory;

    var has_article: ?Article = null;
    for (articles.resources) |article_res| {
        if (std.mem.eql(u8, name, article_res.path)) {
            has_article = .{
                .title = article_res.path,
                .content = article_res.value.file,
            };
        }
    }

    if (has_article) |article| {
        const html = cmark.markdown_to_html(article.content);
        const title = try ctx.arena.dupe(u8, article.title[0 .. article.title.len - 3]);
        std.mem.replaceScalar(u8, title, '_', ' ');

        var body = std.ArrayList(u8).init(ctx.arena);
        try server.util.template(body.writer(), @embedFile("article.html.template"), .{
            .title = title,
            .content = html,
            .global_css = common.global_css,
            .theme = common.dark_theme,
            .global_js = common.global_js,
            .header = common.header,
        });
        return http.Response.file(ctx.arena, .@"text/html", try body.toOwnedSlice());
    } else {
        return http.Response.not_found();
    }
}
