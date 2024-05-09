const std = @import("std");

const ArgsError = error{WrongLen};

pub fn main() !void {
    // Get an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Parse command line arguments into an array of strings
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Print the number of arguments and their values
    if (args.len != 2) {
        return ArgsError.WrongLen;
    }

    const rbytes = args[1];
    const base10num = std.fmt.parseInt(usize, rbytes, 10) catch unreachable;
    const res = try zeckendorf(base10num, allocator);
    defer res.deinit();
    std.debug.print("{s}", .{res.items});
}

fn zeckendorf(n: usize, allocator: std.mem.Allocator) !std.ArrayList(u8) {
    const fiboseq = try fibothreshold(n, allocator);
    defer fiboseq.deinit();

    var result = std.ArrayList(u8).init(allocator);

    var currn = n;
    var i: usize = fiboseq.items.len - 1;
    while (i > 1) : (i -= 1) {
        const fibnum = fiboseq.items[i];
        if (currn >= fibnum) {
            currn -= fibnum;
            try result.append('1');
            if (i > 2) try result.append('0');
            i -= 1; // skip next
        } else {
            try result.append('0');
        }
    }

    return result;
}

fn fibothreshold(max: usize, allocator: std.mem.Allocator) !std.ArrayList(usize) {
    var fib = std.ArrayList(usize).init(allocator);
    errdefer fib.deinit();

    try fib.append(0);
    try fib.append(1);

    while (fib.getLast() < max) {
        const items = fib.items;
        try fib.append(items[items.len - 1] + items[items.len - 2]);
    }

    return fib;
}
