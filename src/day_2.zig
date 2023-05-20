const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const File = std.fs.File;
const Password = struct {
    min: u32,
    max: u32,
    char: u8,
    password: []u8,
    pub fn parse(allocator: Allocator, source: []u8) !Password {
        var splits = std.mem.split(u8, source, " ");
        const min_max = splits.next().?;
        var min_max_split = std.mem.split(u8, min_max, "-");
        const min = min_max_split.next().?;
        const max = min_max_split.next().?;
        const char = splits.next().?;
        const password = splits.next().?;
        const password_heap = try allocator.alloc(u8, password.len);
        std.mem.copy(u8, password_heap, password);

        return .{ .min = try std.fmt.parseInt(u32, min, 10), .max = try std.fmt.parseInt(u32, max, 10), .char = char[0], .password = password_heap };
    }
    pub fn validate_day_one(self: *const Password) bool {
        var count: usize = 0;
        for (self.password) |char| {
            if (char == self.char) {
                count += 1;
            }
        }
        if ((count >= self.min) and (count <= self.max)) {
            return true;
        } else {
            return false;
        }
    }
    pub fn validate_day_two(self: *const Password) bool {
        if (self.password[self.min - 1] == self.char or self.password[self.max - 1] == self.char) {
            if (self.password[self.min - 1] == self.password[self.max - 1]) {
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    }
    pub fn format(self: Password, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("min: {d}, max: {d}, char: {c}, password: {s}", .{ self.min, self.max, self.char, self.password });
    }
};
fn day_one(passwords: *const ArrayList(Password)) !usize {
    var count: usize = 0;
    for (passwords.items) |password| {
        if (password.validate_day_one()) {
            count += 1;
        }
    }
    return count;
}
fn day_two(list: *const ArrayList(Password)) !usize {
    var count: usize = 0;
    for (list.items) |password| {
        if (password.validate_day_two()) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const file = try std.fs.cwd().openFile("input/day_2.txt", .{ .mode = .read_only });
    defer file.close();
    var reader = file.reader();
    var list = ArrayList(Password).init(allocator);
    var buf: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try list.append(try Password.parse(allocator, line));
    }
    std.log.info("part 1: {d}", .{try day_one(&list)});
    std.log.info("part 2: {d}", .{try day_two(&list)});
}
