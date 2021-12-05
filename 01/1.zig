const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var cur: u32 = undefined;
    var prev: u32 = undefined;
    var count: u32 = 0;
    var str: []const u8 = "(N/A - no previous measurement)";
    var first_number = true;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line_s| {
        var line: []u8 = line_s;
        if (line[line.len - 1] == '\r') line = line_s[0 .. line_s.len - 1];
        cur = try std.fmt.parseInt(u32, line, 10);
        if (!first_number) {
            if (cur > prev) {
                count += 1;
                str = "(increased)";
            } else str = "(decreased)";
        } else first_number = false;
        // try std.fmt.format(std.io.getStdOut().writer(), "{d}: {s}\n", .{ cur, str });
        std.log.debug("{d}: {s}", .{ cur, str });
        prev = cur;
    }
    try std.fmt.format(std.io.getStdOut().writer(), "Total: {d}\n", .{count});
}
