const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const c4core = b.addStaticLibrary(.{
        .name = "c4core",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        // .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    c4core.linkLibCpp();
    c4core.addIncludePath("ext/c4core/src");
    c4core.addCSourceFiles(&.{
        "ext/c4core/src/c4/base64.cpp",
        "ext/c4core/src/c4/char_traits.cpp",
        "ext/c4core/src/c4/error.cpp",
        "ext/c4core/src/c4/format.cpp",
        "ext/c4core/src/c4/language.cpp",
        "ext/c4core/src/c4/memory_resource.cpp",
        "ext/c4core/src/c4/memory_util.cpp",
        "ext/c4core/src/c4/utf.cpp",
    }, &.{});

    const lib = b.addStaticLibrary(.{
        .name = "ryml",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        // .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();
    lib.linkLibrary(c4core);
    lib.addIncludePath("src");
    lib.addIncludePath("ext/c4core/src");
    lib.addCSourceFiles(&.{
        "src/c4/yml/node.cpp",
        "src/c4/yml/parse.cpp",
        "src/c4/yml/preprocess.cpp",
        "src/c4/yml/tree.cpp",
    }, &.{});
    lib.installHeadersDirectoryOptions(.{
        .source_dir = "src",
        .install_dir = .header,
        .install_subdir = "ryml",
        .exclude_extensions = &.{"cpp"},
    });
    b.installArtifact(lib);
}
