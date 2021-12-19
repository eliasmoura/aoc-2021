const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();
    const install_all = b.step("install_all", "Install all the days!");
    const run_all = b.step("run_all", "Run all the days!");

    var day: u8 = 0;
    while (day < 25) : (day += 1) {
        const day_str = b.fmt("{:0>2}", .{day + 1});
        const part = [2]u8{ 1, 2 };

        var found_dir = true;
        _ = std.fs.cwd().openDir(day_str, .{}) catch {
            found_dir = false;
            std.debug.print("SKIPPING day {s}\n", .{day_str});
            continue;
        };
        const step_day_key = b.fmt("b_{s}", .{day_str});
        const step_day_desc = b.fmt("Build day {s}", .{day_str});
        const install_day_step = b.step(step_day_key, step_day_desc);

        const run_day_desc = b.fmt("Run day {s}", .{day_str});
        const run_day_step = b.step(day_str, run_day_desc);
        run_all.dependOn(run_day_step);
        for (part) |p| {
            const file_str = b.fmt("{s}/{d}.zig", .{ day_str, p });
            var found_file = true;
            _ = std.fs.cwd().statFile(file_str) catch {
                found_file = false;
                //std.debug.print("SKIPPING day {s} part {d}\n", .{ day_str, p });
                continue;
            };

            if (found_file) {
                const exe = b.addExecutable(b.fmt("day{d:0>2}_{d}", .{ day + 1, p }), file_str);
                exe.setTarget(target);
                exe.setBuildMode(mode);
                exe.install();
                {
                    const step_key = b.fmt("b_{s}_{d}", .{ day_str, p });
                    const step_desc = b.fmt("Build day {s} part {d}", .{ day_str, p });
                    const install_step = b.step(step_key, step_desc);
                    install_step.dependOn(&exe.install_step.?.step);
                    install_day_step.dependOn(&exe.install_step.?.step);
                }
                const run = exe.run();
                while (exe.exec_cmd_args) |a| {
                    std.debug.print("{s}\n", .{a});
                }
                var cwd: [1024]u8 = undefined;
                var s = std.os.getcwd(&cwd) catch continue;
                var buf: [1024]u8 = undefined;
                const new_cwd = std.fmt.bufPrint(&buf, "{s}/{s}/", .{ s, day_str }) catch continue;
                var dest = std.heap.page_allocator.alloc(u8, new_cwd.len) catch continue;
                std.mem.copy(u8, dest, new_cwd);
                run.cwd = dest;
                run.print = true;
                run.step.dependOn(&exe.step);
                if (b.args) |args| {
                    run.addArgs(args);
                }
                const run_desc = b.fmt("Run day {s} part {d}", .{ day_str, p });
                const run_key = b.fmt("{s}_{d}", .{ day_str, p });
                const run_step = b.step(run_key, run_desc);
                run_step.dependOn(&run.step);
                run_day_step.dependOn(&run.step);
            }
        }
        install_all.dependOn(install_day_step);
    }
}
