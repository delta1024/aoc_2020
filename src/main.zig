const std = @import("std");
const day_1 = @import("day_1.zig");
const day_2 = @import("day_2.zig");

pub fn main() !void {
    std.log.info("day 1:", .{});
    try day_1.main();
    std.log.info("day 2:", .{});
    try day_2.main();
}
