const std = @import("std");

pub fn main() !void {
  var file = try std.fs.cwd().openFile("input.txt", .{});
  defer file.close();
  var buf_reader = std.io.bufferedReader(file.reader());
  var in_stream = buf_reader.reader();

  var gamma: u32 = 0;
  var epsilon: u32 = 0;
  var buf: [1024]u8 = undefined;
  var zero_count: [12]u32 = [12]u32{0,0,0,0,0,0,0,0,0,0,0,0};
  var one_count: [12]u32 = [12]u32{0,0,0,0,0,0,0,0,0,0,0,0};
  //var zero_count: [5]u32 = [5]u32{0,0,0,0,0};// for sample.txt
  //var one_count: [5]u32 = [5]u32{0,0,0,0,0};// for sample.txt
  while(try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line_s| {
    var line = line_s;
    if (line[line.len-1] == '\r') line = line_s[0..line_s.len-1];
    for (line) |ch, bit| {
      try std.fmt.format(std.io.getStdOut().writer(), "{d} {c}", .{bit, ch});
      if (ch == '0') {zero_count[bit] += 1;}
      else one_count[bit] +=1;
    }
      try std.fmt.format(std.io.getStdOut().writer(), "\n", .{});
  }
  for (zero_count) |_, index| {
   const bit = zero_count.len-1-index;
    if (zero_count[index] > one_count[index]) {
      epsilon |= @intCast(u32,1)<<@intCast(u5,bit);
    } else
      gamma |= @intCast(u32,1)<<@intCast(u5,bit);
  }
  try std.fmt.format(std.io.getStdOut().writer(), "zero_count: {any}\n", .{zero_count});
  try std.fmt.format(std.io.getStdOut().writer(), "one_count:  {any}\n", .{one_count});
  try std.fmt.format(std.io.getStdOut().writer(), "gamma:   0b{b:0>12} {d}\n", .{gamma, gamma});
  try std.fmt.format(std.io.getStdOut().writer(), "epsilon: 0b{b:0>12} {d}\n", .{epsilon,epsilon});
  try std.fmt.format(std.io.getStdOut().writer(), "gamma*epsilon: {d}\n", .{gamma*epsilon});
}
