const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var pos: u32 = 0;
    var depth: u32 = 0; // submarines don't fly, right?
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line_s| {
        var line: []u8 = line_s;
        if (line[line.len - 1] == '\r') line = line_s[0 .. line_s.len - 1];
        var iter = std.mem.tokenize(u8, line, " ");
        const cmd = iter.next().?;
        const num = try std.fmt.parseUnsigned(u32, iter.next().?, 10);
        if (std.mem.eql(u8, cmd, "forward")) {
            pos += num;
        } else if (std.mem.eql(u8, cmd, "down")) {
            depth += num;
        } else if (std.mem.eql(u8, cmd, "up")) {
            depth -= num;
        }
    }
    try std.fmt.format(std.io.getStdOut().writer(), "pos: {d}\n", .{pos});
    try std.fmt.format(std.io.getStdOut().writer(), "depth: {d}\n", .{depth});
    try std.fmt.format(std.io.getStdOut().writer(), "pos*depth: {d}\n", .{pos * depth});
}
