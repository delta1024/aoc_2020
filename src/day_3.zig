const std = @import("std");
const log = std.log;
const ArayList = std.ArrayList;
const ArenaAllocator = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;
const File = std.fs.File;
const Grid = struct {
    const Pos = struct {
        x: usize = 0,
        y: usize = 0,
        right: usize,
        down: usize,
        pub fn move(self: *Pos) void {
            const grid = @fieldParentPtr(Grid, "position", self);
            const limit = grid.items[0].len;
            self.x += self.right;
            self.y += self.down;
            if (self.x >= limit) {
                self.x = self.x % limit;
            }
        }
    };
    position: Pos,
    items: [][]bool,
    pub fn init(alloctor: Allocator, list: *const ArayList([]u8), position: Pos) !Grid {
        var y_array = try alloctor.alloc([]bool, list.items.len);
        const x_len = list.items[0].len;
        for (y_array) |_, i| {
            y_array[i] = try alloctor.alloc(bool, x_len);
            for (list.items[i]) |c, j| {
                y_array[i][j] = c == '#';
            }
        }
        return .{ .items = y_array, .position = position };
    }
    pub fn validate(self: *Grid) usize {
        // Prime the pump
        self.position.move();
        var count: usize = 0;
        while (self.items.len > self.position.y) : (self.position.move()) {
            if (self.items[self.position.y][self.position.x]) {
                count += 1;
            }
        }
        return count;
    }
    pub fn format(self: Grid, comptime _: []const u8, _: std.fmt.FormatOptions, w: anytype) !void {
        for (self.items) |row| {
            for (row) |point| {
                const c = if (@boolToInt(point) == 1) t: {
                    break :t "t";
                } else f: {
                    break :f "e";
                };
                try w.print("{s}, ", .{c});
            }

            try w.print("\n", .{});
        }
    }
};

fn readFileToList(allocator: Allocator, file: *const File) !ArayList([]u8) {
    var reader = file.reader();
    var buf: [1024]u8 = undefined;
    var list = ArayList([]u8).init(allocator);
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var heap = try allocator.alloc(u8, line.len);
        std.mem.copy(u8, heap, line);
        try list.append(heap);
    }
    return list;
}
pub fn main() !void {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const file = try std.fs.cwd().openFile("input/day_3.txt", .{ .mode = .read_only });
    const list = try readFileToList(allocator, &file);
    var grid_3 = try Grid.init(allocator, &list, .{ .right = 3, .down = 1 });
    var count = grid_3.validate();
    log.info("Part one: {d}", .{count});
    const permutaions: [4]Grid.Pos = .{ .{ .right = 1, .down = 1 }, .{ .right = 5, .down = 1 }, .{ .right = 7, .down = 1 }, .{ .right = 1, .down = 2 } };
    for (permutaions) |pos| {
        var grid = try Grid.init(allocator, &list, pos);
        count *= grid.validate();
    }

    log.info("Part two: {d}", .{count});
    // Puzzle info: https://adventofcode.com/2020/day/3
}
