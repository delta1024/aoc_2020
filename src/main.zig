const std = @import("std");
const day_1 = @import("day_1.zig").main;
const day_2 = @import("day_2.zig").main;
const day_3 = @import("day_3.zig").main;

pub fn main() !void {
    std.log.info("day 1:", .{});
    try day_1();
    std.log.info("day 2:", .{});
    try day_2();
    std.log.info("day 3", .{});
    try day_3();
}
