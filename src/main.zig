const std = @import("std");
const knownFolders = @import("known-folders");

// Print the help menu
pub fn printHelp() void {
    std.debug.print(
        \\asus-wmi-screenpad-ctl [FLAG] [DATA]
        \\
        \\Flags:
        \\  [-s, --set] [UINT] = Set the brightness level (constrained to max level)
        \\  [-a, --add] [INT]  = Add to brightness level (constrained to max level, negative integer for decrease)
        \\  [-m, --max] [UINT] = Set max level (Just because max is set high, does not mean your display can handle it)
        \\
    , .{});
}

// Check if string in string slice
pub fn inStringSlice(haystack: []const []const u8, needle: []const u8) bool {
    for (haystack) |thing| {
        if (std.mem.eql(u8, thing, needle)) {
            return true;
        }
    }
    return false;
}

// Write value to file
pub fn writeIntegerToFile(allocator: std.mem.Allocator, filePath: []const u8, value: u32) !void {
    // Open or create the cache file the file
    const file = try std.fs.openFileAbsolute(filePath, .{ .mode = std.fs.File.OpenMode.write_only });
    defer file.close();

    // Convert value to string
    const string = try std.fmt.allocPrint(
        allocator,
        "{d}",
        .{value},
    );
    defer allocator.free(string);

    // Write to file
    try file.writeAll(string);
}

// Strips a character from a string
pub fn stripCharacterFromString(allocator: std.mem.Allocator, string: []const u8, char: []const u8) ![]u8 {
    const size = std.mem.replacementSize(u8, string, char, "");
    const output = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, string, char, "", output);
    return output;
}

// Gets a 3 byte string number from file (creates a new file with default value if none)
pub fn getStringIntegerFromFile(allocator: std.mem.Allocator, filePath: []const u8, default: u32) !u32 {
    // Open or create the cache file the file
    const file = std.fs.openFileAbsolute(filePath, .{ .mode = std.fs.File.OpenMode.read_only }) catch {
        var f = try std.fs.createFileAbsolute(filePath, .{ .read = true });

        // Convert value to string
        const string = try std.fmt.allocPrint(
            allocator,
            "{d}",
            .{default},
        );
        defer allocator.free(string);

        // Write to file
        try f.writeAll(string);
        return default;
    };
    defer file.close();

    // Grab cache info from file
    const file_buffer = try file.readToEndAlloc(allocator, 1000);
    defer allocator.free(file_buffer);

    const stripped = try stripCharacterFromString(allocator, file_buffer, "\n");
    defer allocator.free(stripped);

    return try std.fmt.parseInt(u32, stripped, 10);
}

pub fn main() !void {
    // Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    // Define constants
    const flags: [6][]const u8 = .{ "-s", "--set", "-a", "--add", "-m", "--max" };
    const devicePath: []const u8 = "/sys/class/leds/asus::screenpad/brightness";

    const globalCachePath: []const u8 = (try knownFolders.getPath(allocator, knownFolders.KnownFolder.cache)).?;
    const cachePath: []const u8 = try std.mem.concat(allocator, u8, &[_][]const u8{ globalCachePath, "/asus-wmi-screenpad-ctl.txt" });
    defer allocator.free(globalCachePath);
    defer allocator.free(cachePath);

    // Grab command line args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Check basic command line arguments
    if (args.len != 3 or !inStringSlice(&flags, args[1])) {
        printHelp();
        return;
    }

    const flag: []u8 = args[1];
    const value: []u8 = args[2];

    // Get cached max value
    var max: u32 = try getStringIntegerFromFile(allocator, cachePath, 100);

    // Complete the
    if (std.mem.eql(u8, flag, "-s") or std.mem.eql(u8, flag, "--set")) {
        // Parse the integer
        var integer: u32 = std.fmt.parseInt(u32, value, 10) catch {
            std.log.err("Error: Did not enter a valid set value.", .{});
            printHelp();
            return;
        };

        // Clamp
        if (integer > max) {
            integer = max;
        }

        // Write to device
        try writeIntegerToFile(allocator, devicePath, integer);
    } else if (std.mem.eql(u8, flag, "-a") or std.mem.eql(u8, flag, "--add")) {
        // Parse the integer
        var integer: i32 = std.fmt.parseInt(i32, value, 10) catch {
            std.log.err("Error: Did not enter a valid add value.", .{});
            printHelp();
            return;
        };

        // Grab current
        const current: u32 = try getStringIntegerFromFile(allocator, devicePath, 100);
        integer += @intCast(current);

        // Clamp
        if (integer > max) {
            integer = @intCast(max);
        } else if (integer < 0) {
            integer = 0;
        }

        // Write to device
        try writeIntegerToFile(allocator, devicePath, @intCast(integer));
    } else if (std.mem.eql(u8, flag, "-m") or std.mem.eql(u8, flag, "--max")) {
        // Parse the integer
        const integer: u32 = std.fmt.parseInt(u32, value, 10) catch {
            std.log.err("Error: Did not enter a valid max value.", .{});
            printHelp();
            return;
        };

        // Set max
        max = integer;
    }

    // Write to cache
    try writeIntegerToFile(allocator, cachePath, max);
}
