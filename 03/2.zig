const std = @import("std");

fn new_list(list: [][12] u8, bit: u8, one: bool, size: u32) ![][12]u8 {
  var allocator = std.heap.page_allocator;
  var result = try allocator.alloc([12]u8, size);
  var it :u32 = 0;
  var ch:u8 = if (one) '1' else '0';
  for (list) |item| {
    if (item[bit] == ch) {
      result[it] = item;
      it+=1;
    }
  }
  return result;
}

fn update_list(list: [][12] u8, bit: u8, most_common: bool, eq_one: bool) ![][12]u8 {
  var result = list.len;
  var one: u32 = 0;
  var zero: u32 = 0;
  for (list) |item| {
    if (item[bit] == '0') {
      zero+=1;
    } else one +=1;
  }
  if (one==zero){
    if (eq_one) {
      return new_list(list, bit, true, one);
    } else {
      return new_list(list, bit, false, zero);
    }
  } else {
    var val = one;
    var val_one = true;

    if (one > zero) {
      if (!most_common){
        val = zero;
        val_one = false;
      } else {
        val = one;
        val_one = true;
      }
    } else {
      if (!most_common){
        val = one;
        val_one = true;
      } else {
        val = zero;
        val_one = false;
      }
    }
    return new_list(list, bit, val_one, val);
  }
  return result;
}

pub fn main() !void {
  var file = try std.fs.cwd().openFile("input.txt", .{});
  defer file.close();
  var buf_reader = std.io.bufferedReader(file.reader());
  var in_stream = buf_reader.reader();

  var s = try file.stat();

  const allocator = std.heap.page_allocator;
  var buf = try allocator.alloc(u8, s.size);
  _ = try in_stream.readAll(buf);
  //var zero_count: [5]u32 = [5]u32{0,0,0,0,0};// for sample.txt
  //var one_count: [5]u32 = [5]u32{0,0,0,0,0};// for sample.txt
  var bit: u8 = 0;
  var lines = std.mem.tokenize(u8, buf, "\n");
  var list_t = try allocator.alloc([12]u8, 100);
  var it : u32 = 0;
  while (true) {
    if (it == list_t.len) list_t = try allocator.realloc(list_t, list_t.len*2);
    if(lines.next()) |item| {
      list_t[it] = item[0..12].*;
    }
    else {break;}
    it+=1;
  }
  list_t = list_t[0..list_t.len-1];
  var list_co2 = list_t[0..it];
  var list_o2: [][12]u8 = undefined;
  list_o2 = try std.heap.page_allocator.alloc([12]u8, list_co2.len);
  std.mem.copy([12]u8, list_o2,list_co2);
  while(true) {
    list_o2 = try update_list(list_o2, bit, true, true);
    if(list_o2.len >1) bit +=1 else break;
    if(bit ==12) break;
  }
  bit = 0;
  while(true) {
    list_co2 = try update_list(list_co2, bit, false, false);
    if(list_co2.len > 1) bit +=1 else break;
    if(bit ==12) break;
  }
  var o2 = try std.fmt.parseUnsigned(u32, &list_o2[0], 2);
  var co2 = try std.fmt.parseUnsigned(u32, &list_co2[0], 2);
  try std.fmt.format(std.io.getStdOut().writer(), "oxygen generator rating: 0b{b:0>12} {d}\n", .{o2, o2});
  try std.fmt.format(std.io.getStdOut().writer(), "CO2 scruber rating:  0b{b:0>12} {d}\n", .{co2, co2});
  try std.fmt.format(std.io.getStdOut().writer(), "o2*co2: {d}\n", .{o2*co2});
}
