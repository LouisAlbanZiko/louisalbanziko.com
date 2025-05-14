const std = @import("std");
const c = @cImport({
    @cInclude("cmark.h");
    @cInclude("cmark_export.h");
    @cInclude("node.h");
});

pub const NodeType = enum(i32) {
    CMARK_NODE_NONE = c.CMARK_NODE_NONE,
    CMARK_NODE_DOCUMENT = c.CMARK_NODE_DOCUMENT,
    CMARK_NODE_BLOCK_QUOTE = c.CMARK_NODE_BLOCK_QUOTE,
    CMARK_NODE_LIST = c.CMARK_NODE_LIST,
    CMARK_NODE_ITEM = c.CMARK_NODE_ITEM,
    CMARK_NODE_CODE_BLOCK = c.CMARK_NODE_CODE_BLOCK,
    CMARK_NODE_HTML_BLOCK = c.CMARK_NODE_HTML_BLOCK,
    CMARK_NODE_CUSTOM_BLOCK = c.CMARK_NODE_CUSTOM_BLOCK,
    CMARK_NODE_PARAGRAPH = c.CMARK_NODE_PARAGRAPH,
    CMARK_NODE_HEADING = c.CMARK_NODE_HEADING,
    CMARK_NODE_THEMATIC_BREAK = c.CMARK_NODE_THEMATIC_BREAK,
    CMARK_NODE_TEXT = c.CMARK_NODE_TEXT,
    CMARK_NODE_SOFTBREAK = c.CMARK_NODE_SOFTBREAK,
    CMARK_NODE_LINEBREAK = c.CMARK_NODE_LINEBREAK,
    CMARK_NODE_CODE = c.CMARK_NODE_CODE,
    CMARK_NODE_HTML_INLINE = c.CMARK_NODE_HTML_INLINE,
    CMARK_NODE_CUSTOM_INLINE = c.CMARK_NODE_CUSTOM_INLINE,
    CMARK_NODE_EMPH = c.CMARK_NODE_EMPH,
    CMARK_NODE_STRONG = c.CMARK_NODE_STRONG,
    CMARK_NODE_LINK = c.CMARK_NODE_LINK,
    CMARK_NODE_IMAGE = c.CMARK_NODE_IMAGE,
};

pub fn markdown_to_html(md: [:0]const u8) [:0]u8 {
    //pub fn markdown_to_html(md: [:0]const u8) struct {
    //    navigation: [:0]u8,
    //    html: [:0]u8,
    //} {
    //const doc = c.cmark_parse_document(md.ptr, md.len, 0);
    //defer c.cmark_node_free(doc);
    //
    //const iter = c.cmark_iter_new(doc);
    //defer c.cmark_iter_free(iter);
    //
    //var last_level: usize = 1;
    //while (c.cmark_iter_next(iter) != c.CMARK_EVENT_DONE) {
    //    const node = c.cmark_iter_get_node(iter);
    //    const node_type: NodeType = @enumFromInt(node.?.*.type);
    //    if (node_type == .CMARK_NODE_HEADING) {
    //        const node_heading = node.?.*.as.heading;
    //        if (node_heading.level > last_level) {
    //
    //        }
    //        std.debug.print("{d},{d},{}\n", .{ node_heading.internal_offset, node_heading.level, node_heading.setext });
    //    }
    //    std.debug.print("{s}\n", .{@tagName(node_type)});
    //}

    const c_string = c.cmark_markdown_to_html(md.ptr, md.len, 0);
    return std.mem.span(c_string);
}
