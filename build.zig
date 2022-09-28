const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    ensureSubmodules(b.allocator) catch |err| @panic(@errorName(err));

    const exe = b.addExecutable("main", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.addCSourceFile("src/main.cpp", &[_][]const u8{});
    exe.addIncludePath("third_party/eigen");
    exe.addIncludePath("third_party/spectra/include");

    exe.defineCMacro("EIGEN_FAST_MATH", "1");
    exe.defineCMacro("THREAD_SAFE", "");
    exe.linkSystemLibrary("m");

    if (target.isNative()) {
        exe.defineCMacro("EIGEN_USE_BLAS", "");
        exe.linkSystemLibrary("blas");
        exe.linkSystemLibrary("omp");
        if (target.isDarwin()) {
            exe.linkFramework("Accelerate");
            exe.addIncludePath("/opt/homebrew/include");
            exe.addIncludePath("/usr/local/include");
            exe.addLibraryPath("/opt/homebrew/lib");
            exe.addLibraryPath("/usr/local/lib");
        }
    }

    if (b.is_release) {
        exe.defineCMacro("EIGEN_NO_DEBUG", "");
    }

    exe.linkLibCpp();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
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
