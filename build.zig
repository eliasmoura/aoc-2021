const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    var day: u8 = 1;
    while (day <= 25) : (day += 1) {
        const day_str = b.fmt("{:0>2}", .{day});
        const part_one = b.fmt("{s}/1.zig", .{day_str});
        const part_two = b.fmt("{s}/2.zig", .{day_str});

        var found_file = true;
        _ = std.fs.cwd().statFile(part_one) catch {
            found_file = false;
            std.debug.print("SKIPPING day {s} part one\n", .{day_str});
        };
        if (found_file) {
            const exe_one = b.addExecutable(b.fmt("day{d:0>2}_1", .{day}), part_one);
            exe_one.setTarget(target);
            exe_one.setBuildMode(mode);
            exe_one.install();
        }
        found_file = true;
        _ = std.fs.cwd().statFile(part_two) catch {
            found_file = false;
            std.debug.print("SKIPPING day {s} part two\n", .{day_str});
        };
        if (found_file) {
            const exe_two = b.addExecutable(b.fmt("day{d:0>2}_2", .{day}), part_two);
            exe_two.setTarget(target);
            exe_two.setBuildMode(mode);
            exe_two.install();
        }
    }
}
