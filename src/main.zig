const std = @import("std");
const testing = std.testing;

extern fn consoleLog(arg: u32) void;

const checkerboard_size: usize = 8;
var checkerboard_buffer = std.mem.zeroes([checkerboard_size][checkerboard_size][4]u8);

// checkerboard_size * 2, where each pixel is 4 bytes (rgba)
export fn getCheckerboardBufferPointer() [*]u8 {
    return @ptrCast(&checkerboard_buffer);
}

export fn getCheckerboardSize() usize {
    return checkerboard_size;
}

export fn colorCheckerboard(
    dark_value_red: u8,
    dark_value_green: u8,
    dark_value_blue: u8,
    light_value_red: u8,
    light_value_green: u8,
    light_value_blue: u8,
) void {
    // Since Linear memory is a 1 dimensional array, but we want a grid
    // we will be doing 2d to 1d mapping
    // https://softwareengineering.stackexchange.com/questions/212808/treating-a-1d-data-structure-as-2d-grid
    for (&checkerboard_buffer, 0..) |*row, y| {
        for (row, 0..) |*square, x| {
            // Set our default case to be dark squares
            var is_dark_square = true;

            // We should change our default case if
            // We are on an odd y
            if ((y % 2) == 0) {
                is_dark_square = false;
            }

            // Lastly, alternate on our x value
            if ((x % 2) == 0) {
                is_dark_square = !is_dark_square;
            }

            // Now that we determined if we are dark or light,
            // Let's set our square value
            var square_value_red = dark_value_red;
            var square_value_green = dark_value_green;
            var square_value_blue = dark_value_blue;
            if (!is_dark_square) {
                square_value_red = light_value_red;
                square_value_green = light_value_green;
                square_value_blue = light_value_blue;
            }

            // Finally store the values.
            square.*[0] = square_value_red;
            square.*[1] = square_value_green;
            square.*[2] = square_value_blue;
            square.*[3] = 255;
        }
    }
}
