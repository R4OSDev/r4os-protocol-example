const r4os = @import("r4os");

pub const op_echo: u32 = 1;
pub const op_checksum: u32 = 2;

comptime {
    asm (r4os.r4dev.protocolEntriesAsm("example_protocol_init", "example_protocol_shutdown", "example_protocol_query", "example_protocol_dispatch"));
}

export fn example_protocol_init(api: *const r4os.r4dev.ProtocolApi) callconv(.c) i32 {
    var ctx = r4os.r4dev.ProtocolContext.init(api);
    ctx.logInfo("EXAMPLE.R4P init");
    _ = ctx.registerRole("misc.example", .misc, 0);
    _ = ctx.setStatus(.active, "example protocol active");
    return 0;
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
    var i: usize = 0;
    while (i < input.len) : (i += 1) output[i] = input[i];
    out_buffer.len = @intCast(input.len);
    return 0;
}

fn checksum(in_buffer: *const r4os.abi.ProtocolBuffer, out_buffer: *r4os.abi.ProtocolBuffer) i32 {
    const input = inputBytes(in_buffer) orelse return -2;
    const output = outputBytes(out_buffer) orelse return -2;
    if (output.len < 4) return -5;
    var sum: u32 = 0;
    for (input) |value| sum +%= value;
    output[0] = @intCast(sum & 0xFF);
    output[1] = @intCast((sum >> 8) & 0xFF);
    output[2] = @intCast((sum >> 16) & 0xFF);
    output[3] = @intCast((sum >> 24) & 0xFF);
    out_buffer.len = 4;
    return 0;
}

fn inputBytes(buffer: *const r4os.abi.ProtocolBuffer) ?[]const u8 {
    if (buffer.data == null) return null;
    const ptr: [*]const u8 = @ptrCast(buffer.data.?);
    return ptr[0..@intCast(buffer.len)];
}

fn outputBytes(buffer: *const r4os.abi.ProtocolBuffer) ?[]u8 {
    if (buffer.data == null) return null;
    const ptr: [*]u8 = @ptrCast(buffer.data.?);
    return ptr[0..@intCast(buffer.capacity)];
}

fn note(comptime text: []const u8) [64]u8 {
    var out: [64]u8 = .{0} ** 64;
    @memcpy(out[0..text.len], text);
    return out;
}
