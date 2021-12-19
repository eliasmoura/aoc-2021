const std = @import("std");

const board_t = [5][5]struct { number: u8, drawn: bool };

pub fn main() !void {
  var file = try std.fs.cwd().openFile("input.txt", .{});
  defer file.close();
  var buf_reader = std.io.bufferedReader(file.reader());
  var in_stream = buf_reader.reader();
  var s = try file.stat();
  var buffer = try std.heap.page_allocator.alloc(u8, s.size);
  _ = try in_stream.readAll(buffer);

  var lines_t = std.mem.tokenize(u8, buffer, "\n");
  var drawn_numbers_line = lines_t.next().?;
  const drawn_numbers_count = std.mem.count(u8, drawn_numbers_line, ",") + 1;
  var drawn_numbers_str = std.mem.tokenize(u8, drawn_numbers_line, ",");
  var drawn_numbers = try std.heap.page_allocator.alloc(u8, drawn_numbers_count);
  var i: u32 = 0;
  while (drawn_numbers_str.next()) |num| {
    drawn_numbers[i] = try std.fmt.parseUnsigned(u8, num, 10);
    i += 1;
  }

  const boards_count = std.mem.count(u8, buffer, "\n\n");
  var boards_to_win_count = boards_count;
  var boards_to_win = try std.heap.page_allocator.alloc(usize, boards_to_win_count);
  var boards_to_win_index :usize = 0;
  var boards = try std.heap.page_allocator.alloc(board_t, boards_count);
  var boards_str = std.mem.split(u8, buffer, "\n\n");
  _ = boards_str.next().?;
  var board_index: u32 = 0;
  while (boards_str.next()) |board_str| {
    var board_lines = std.mem.tokenize(u8, board_str, "\n");
    var line_index: u32 = 0;
    while (board_lines.next()) |line| {
      var numbers_str = std.mem.tokenize(u8, line, " ");
      var col_index: u32 = 0;
      while (numbers_str.next()) |num_str| {
        const num = try std.fmt.parseUnsigned(u8, num_str, 10);
        boards[board_index][line_index][col_index] = .{ .number = num, .drawn = false };
        col_index += 1;
      }
      line_index += 1;
    }
    board_index += 1;
  }

  var sum: u32 = 0;
  var tot: u64 = 0;
  all: for (drawn_numbers) |num, index| {
    for (boards) |board, board_index_s| {
      for (board) |line, line_index| {
        for (line) |col, col_index| {
          if (col.number == num) {
            boards[board_index_s][line_index][col_index].drawn = true;
            if (index > 4) {
              var won = false;
              if ((boards[board_index_s][line_index][0].drawn and
                   boards[board_index_s][line_index][1].drawn and
                   boards[board_index_s][line_index][2].drawn and
                   boards[board_index_s][line_index][3].drawn and
                   boards[board_index_s][line_index][4].drawn) or
                  (boards[board_index_s][0][col_index].drawn and
                   boards[board_index_s][1][col_index].drawn and
                   boards[board_index_s][2][col_index].drawn and
                   boards[board_index_s][3][col_index].drawn and
                   boards[board_index_s][4][col_index].drawn)) {
                won = true;
              }
              if (won) {
                if (boards_to_win_index == 0) {
                  boards_to_win[boards_to_win_index] = board_index_s;
                  boards_to_win_index+=1;
                      boards_to_win_count -=1;
                } else {
                  var ii :u32 = 0;
                  var new: bool = true;
                  while(ii < boards_to_win_index) {
                    if (boards_to_win[ii] == board_index_s) {
                      new = false;
                      break;
                    }
                    ii+=1;
                  }
                  if (new) {
                      boards_to_win[boards_to_win_index] = board_index_s;
                      boards_to_win_index+=1;
                      boards_to_win_count -=1;
                  }
                }
                if (boards_to_win_count == 0) {
                  for (boards[board_index_s]) |l| {
                    for (l) |c| {
                      if (!c.drawn)
                      sum += c.number;
                    }
                  }

                  std.debug.print("{} {} {}\n", .{board_index_s, sum, num});
                  tot = sum * num;
                  break :all;
                }
                }
            }
          }
        }
      }
    }
  }
  for (boards) |board, board_index_s| {
    std.debug.print("BOARD: {d}\n", .{board_index_s});
    for (board) |line| {
      for (line) |col| {
        std.debug.print("{d}", .{col.number});
        if (col.drawn) {
          std.debug.print("*", .{});
        }
        std.debug.print(" ", .{});
      }
      std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
  }

  std.debug.print("Answer: {d}\n", .{tot});
}
