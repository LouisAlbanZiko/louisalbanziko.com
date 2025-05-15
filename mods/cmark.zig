const cmark = @import("cmark");
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
pub const markdown_to_html = cmark.markdown_to_html;
