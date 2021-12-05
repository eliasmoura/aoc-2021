const std = @import("std");

const slide = struct {
  total: u32 = 0,
  count: u8 = 0
};

fn sum_slide(s: *slide, val: u32) void {
  switch (slide.count) {
    0=> {
      s.count +=1;
      s.total = val;
    },
    1,2=> {

      s.count +=1;
      s.total += val;
    },
    else => {
      s.count = 0;
      s.total = 0;
    }
  }
}

pub fn main() !void {
  var file = try std.fs.cwd().openFile("input.txt", .{});
  defer file.close();

  var buf_reader = std.io.bufferedReader(file.reader());
  var in_stream = buf_reader.reader();
  var buf: [1024]u8 = undefined;
  var cur: i32 = undefined;
  var count: u32 = 0;
  var str: []const u8 = "(N/A - no previous measurement)";
  var a: i32 = 0;
  var b: i32 = 0;
  var c: i32 = 0;
  var slide_c: u8 = 0;
  var diff_computed = false;
  var index: u32 = 0;
  while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line_s| {
    var line: []u8 = line_s;
    if (line[line.len - 1] == '\r') line = line_s[0 .. line_s.len - 1];
    cur = try std.fmt.parseInt(i32, line, 10);
    var diff: i32 = undefined;
    switch(slide_c) {
      0 => {
        a= cur;//1
        slide_c +=1;
      },
      1=> {
        a+=cur;//2
        b=cur;//1
        slide_c +=1;
      },
      2=>{
        a+=cur;//3
        std.log.debug("{d}: {d} {s}", .{ index, a, str });
        index+=1;
        b+=cur;//2
        c=cur;//1
        slide_c +=1;
      },
      3=> {
        b+=cur;//3
        std.log.debug("{d}: {d}", .{index, b});
        index+=1;
        diff = @intCast(i32, a-b);
        diff_computed = true;
        c+=cur;//2
        a=cur;//1
        slide_c +=1;
      },
      4=> {
        c+=cur;//3
        std.log.debug("{d}: {d}", .{index, c});
        index+=1;
        a+=cur;//2
        diff = @intCast(i32, b-c);
        b=cur;//1
        slide_c +=1;
      },
      5=> {
        a+=cur;//3
        b+=cur;//2
        diff = @intCast(i32, c-a);
        c=cur;//1
        slide_c=3;
      },
      else => {}
    }
    if (diff_computed) {
      if(diff == 0) {
        str = "(no change)";
      } else if (diff < 0){
        str = "(increased)";
        count += 1;
      } else {
        str = "(decreased)";
      }
    std.log.debug("{s}: ", .{str});
    }
  }
  try std.fmt.format(std.io.getStdOut().writer(), "Total: {d}\n", .{count});
}
