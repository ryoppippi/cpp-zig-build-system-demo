const std = @import("std");
const Build = std.Build;
const Step = Build.Step;
const Compile = Step.Compile;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "main",
        .target = target,
        .optimize = optimize,
    });

    exe.step.dependOn(&b.addSystemCommand(&.{ "git", "submodule", "update", "--init", "--recursive" }).step);

    exe.addCSourceFile(.{ .file = .{ .path = "src/main.cpp" }, .flags = &.{} });
    exe.addIncludePath(.{ .path = "third_party/eigen" });
    exe.addIncludePath(.{ .path = "third_party/spectra/include" });

    exe.defineCMacro("EIGEN_FAST_MATH", "1");
    exe.defineCMacro("THREAD_SAFE", "");
    exe.linkSystemLibrary("m");

    if (target.query.isNative()) {
        exe.defineCMacro("EIGEN_USE_BLAS", "");
        exe.linkSystemLibrary("blas");
        exe.linkSystemLibrary("omp");
        if (target.result.isDarwin()) {
            // exe.linkFramework("Accelerate");
            exe.addIncludePath(.{ .path = "/opt/homebrew/include" });
            exe.addLibraryPath(.{ .path = "/usr/local/include" });
            exe.addLibraryPath(.{ .path = "/opt/homebrew/lib" });
            exe.addLibraryPath(.{ .path = "/usr/local/lib" });
        }
    }

    if (optimize != .Debug) {
        exe.defineCMacro("EIGEN_NO_DEBUG", "");
    }

    exe.linkLibCpp();
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
