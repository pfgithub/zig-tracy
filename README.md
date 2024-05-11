For mach-nominated zig version [2024.3.0-mach](https://machengine.org/about/nominated-zig/#202430-mach)

Tracy packaged for the zig build system. Compiles client & profiler.

# Issues:

- Does not provide zig bindings - you have to provide these yourself
  - Sample here: https://github.com/ziglang/zig/blob/master/src/tracy.zig
  - Future solution: b.addTranslateC of the tracy c bindings?
- Does not support cross-compilation
  - Put tracy builds on a flag like `-Denable_tracy` to not break cross-compilation for your app
- TODO:
  - Compile tracy profiler for mac
  - Compile tracy profiler for windows

# Usage:

```
zig fetch --save=tracy https://github.com/pfgithub/zig-tracy/archive/LATEST_COMMIT_HASH.tar.gz
```

```zig
if (enable_tracy) {
    const tracy_dep = b.dependency("tracy", .{
        .target = target,
        .optimize = optimize,
    });

    app.compile.linkLibrary(tracy_dep.artifact("tracy_client"));

    // optional
    b.installArtifact(tracy_dep.artifact("tracy_profiler"));
}
```

Building tracy_profiler

- (windows) TODO
- (mac) TODO
- (linux) System must have installed:
  - `capstone-devel`
  - `libzstd-devel`
  - `dbus-devel`
