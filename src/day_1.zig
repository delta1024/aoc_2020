const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const ArenaAllocator = std.heap.ArenaAllocator;
const File = std.fs.File;
const ExpenseReport = struct {
    const WANTED_SUM = 2020;
    location: usize = 0,
    cur: u32 = 0,
    expenses: ArrayList(u32),
    pub fn init(allocator: Allocator, source: *const File) !ExpenseReport {
        var expenses = ArrayList(u32).init(allocator);
        var stream = source.reader();
        var buf: [1024]u8 = undefined;
        while (try stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            const num = try std.fmt.parseInt(u32, line, 10);
            try expenses.append(num);
        }
        return .{
            .expenses = expenses,
        };
    }
    pub fn part_one(self: *ExpenseReport) ?u32 {
        while (true) {
            if (self.location == self.expenses.items.len) {
                break;
            }
            self.cur = self.expenses.items[self.location];
            self.location += 1;
            for (self.expenses.items[self.location..]) |num| {
                if (num + self.cur == WANTED_SUM) {
                    return num * self.cur;
                }
            }
        }
        return null;
    }
    pub fn part_two(self: *ExpenseReport) ?u32 {
        while (true) {
            if (self.location == self.expenses.items.len) {
                break;
            }
            self.cur = self.expenses.items[self.location];
            self.location += 1;
            for (self.expenses.items[self.location..]) |num, i| {
                if (i + 1 == self.expenses.items.len) {
                    break;
                }

                for (self.expenses.items[(i + 1)..]) |num_two| {
                    if (self.cur + num + num_two == WANTED_SUM) {
                        return (self.cur * num * num_two);
                    }
                }
            }
        }
        return null;
    }
    pub fn reset(self: *ExpenseReport) void {
        self.cur = 0;
        self.location = 0;
    }
};
pub fn main() !void {
    const file = try std.fs.cwd().openFile("input/day_1.txt", .{ .mode = .read_only });
    defer file.close();
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var report = try ExpenseReport.init(allocator, &file);
    std.log.info("part 1: {any}", .{report.part_one()});
    report.reset();
    std.log.info("part 2: {any}", .{report.part_two()});
}
