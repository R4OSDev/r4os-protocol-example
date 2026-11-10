const r4os = @import("r4os");

pub const op_echo: u32 = 1;
pub const op_checksum: u32 = 2;

comptime {
    if (!@import("builtin").is_test) asm (r4os.technical2.protocolEntriesAsm("example_protocol_init", "example_protocol_shutdown", "example_protocol_query", "example_protocol_dispatch"));
}

export fn example_protocol_init(api: *const r4os.r4dev.ProtocolApi2) callconv(.c) i32 {
    const ctx = r4os.r4dev.ProtocolContext2.init(api);
    if (!ctx.requires(.{ "register_role", "set_status" })) return r4os.abi.err_no_fn;
    const registered = ctx.registerRole("misc.example", .misc, 0);
    if (registered != 0) return registered;
    return ctx.setStatus(.active, "example protocol active");
}

export fn example_protocol_shutdown() callconv(.c) i32 {
    return 0;
}

export fn example_protocol_query(out: *r4os.abi.ProtocolStatus) callconv(.c) i32 {
    out.* = .{
        .state = @intFromEnum(r4os.abi.ProtocolState.active),
        .flags = 0,
        .last_error = 0,
        .reserved = 0,
        .note = note("example protocol ready"),
    };
    return 0;
}

export fn example_protocol_dispatch(op: u32, in_buffer: *const r4os.abi.ProtocolBuffer, out_buffer: *r4os.abi.ProtocolBuffer) callconv(.c) i32 {
    return switch (op) {
        op_echo => echo(in_buffer, out_buffer),
        op_checksum => checksum(in_buffer, out_buffer),
        else => -4,
    };
}

fn echo(in_buffer: *const r4os.abi.ProtocolBuffer, out_buffer: *r4os.abi.ProtocolBuffer) i32 {
    const input = inputBytes(in_buffer) orelse return -2;
    const output = outputBytes(out_buffer) orelse return -2;
    if (input.len > output.len) return -5;
    var writer = r4os.binary_cursor.Writer.init(output) catch return -2;
    writer.put(input) catch return -5;
    out_buffer.len = @intCast(input.len);
    return 0;
}

fn checksum(in_buffer: *const r4os.abi.ProtocolBuffer, out_buffer: *r4os.abi.ProtocolBuffer) i32 {
    const input = inputBytes(in_buffer) orelse return -2;
    const output = outputBytes(out_buffer) orelse return -2;
    if (output.len < 4) return -5;
    var sum: u32 = 0;
    for (input) |value| sum +%= value;
    var writer = r4os.binary_cursor.Writer.init(output) catch return -2;
    writer.writeInt(u32, sum, .little) catch return -5;
    out_buffer.len = 4;
    return 0;
}

fn inputBytes(buffer: *const r4os.abi.ProtocolBuffer) ?[]const u8 {
    const data = buffer.data orelse return null;
    if (buffer.flags != 0 or buffer.reserved != 0 or buffer.len > buffer.capacity) return null;
    const storage = r4os.binary_cursor.Span{ .address = @intFromPtr(data), .length = buffer.capacity };
    storage.validate() catch return null;
    return (r4os.binary_cursor.Span{ .address = storage.address, .length = buffer.len }).bytes() catch null;
}

fn outputBytes(buffer: *const r4os.abi.ProtocolBuffer) ?[]u8 {
    const data = buffer.data orelse return null;
    if (buffer.flags != 0 or buffer.reserved != 0 or buffer.len > buffer.capacity) return null;
    const storage = r4os.binary_cursor.Span{ .address = @intFromPtr(data), .length = buffer.capacity };
    storage.validate() catch return null;
    const ptr: [*]u8 = @ptrCast(data);
    return ptr[0..buffer.capacity];
}

fn note(comptime text: []const u8) [64]u8 {
    var out: [64]u8 = .{0} ** 64;
    @memcpy(out[0..text.len], text);
    return out;
}
