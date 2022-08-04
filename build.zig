const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    ensureSubmodules(b.allocator) catch |err| @panic(@errorName(err));

    const exe = b.addExecutable("main", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addCSourceFile("src/main.cpp", &[_][]const u8{
        "-std=c++14",
        "-stdlib=libc++",
    });
    if (builtin.os.tag == .macos) {
        exe.linkFramework("Accelerate");
    }
    exe.addIncludeDir("third_party/eigen");
    exe.defineCMacroRaw("EIGEN_USE_BLAS");
    exe.defineCMacroRaw("EIGEN_FAST_MATH=1");
    exe.defineCMacroRaw("EIGEN_NO_DEBUG");
    exe.defineCMacroRaw("NDEBUG");
    exe.defineCMacroRaw("THREAD_SAFE");
    exe.linkLibCpp();
    exe.linkSystemLibrary("m");
    exe.linkSystemLibrary("blas");
    exe.install();
}

fn ensureSubmodules(allocator: std.mem.Allocator) !void {
    if (std.process.getEnvVarOwned(allocator, "NO_ENSURE_SUBMODULES")) |no_ensure_submodules| {
        if (std.mem.eql(u8, no_ensure_submodules, "true")) return;
    } else |_| {}
    var child = std.ChildProcess.init(&.{ "git", "submodule", "update", "--init", "--recursive" }, allocator);
    child.cwd = (comptime thisDir());
    child.stderr = std.io.getStdErr();
    child.stdout = std.io.getStdOut();
    _ = try child.spawnAndWait();
}

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
