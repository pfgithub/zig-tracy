const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tracy_dep = b.dependency("tracy", .{});

    const tracy_mod = b.addStaticLibrary(.{
        .name = "tracy_client",
        .target = target,
        .optimize = optimize,
    });

    tracy_mod.addIncludePath(tracy_dep.path("."));
    tracy_mod.addCSourceFile(.{
        .file = tracy_dep.path("public/TracyClient.cpp"),
        .flags = &.{
            "-DTRACY_ENABLE=1",
            "-fno-sanitize=undefined",
            "-D_WIN32_WINNT=0x601", // https://github.com/ziglang/zig/blob/ac21ade667f0f42b8b1aec5831cbc99cbaed8565/build.zig#L374
        },
    });
    tracy_mod.linkLibC();
    tracy_mod.linkLibCpp();

    // tracy client won't cross-compile to windows because it needs a bunch of libraries
    if (target.result.os.tag == .windows) {
        tracy_mod.linkSystemLibrary("Advapi32");
        tracy_mod.linkSystemLibrary("User32");
        tracy_mod.linkSystemLibrary("Ws2_32");
        tracy_mod.linkSystemLibrary("DbgHelp");
    }

    b.installArtifact(tracy_mod);

    const glfw_for_tracy_dep = b.dependency("glfw", .{ .target = target, .optimize = optimize });
    const tracy_exe = b.addExecutable(.{
        .name = "tracy",
        .target = target,
        .optimize = optimize,
    });
    tracy_exe.linkLibrary(glfw_for_tracy_dep.artifact("glfw"));
    tracy_exe.linkSystemLibrary("capstone"); // https://github.com/capstone-engine/capstone
    tracy_exe.linkSystemLibrary("zstd");
    if (target.result.os.tag == .linux) {
        tracy_exe.linkSystemLibrary("dbus-1");
    }
    tracy_exe.addCSourceFiles(.{
        .root = tracy_dep.path("."),
        .files = &[_][]const u8{
            "profiler/src/profiler/TracyBadVersion.cpp",
            "profiler/src/profiler/TracyColor.cpp",
            "profiler/src/profiler/TracyEventDebug.cpp",
            "profiler/src/profiler/TracyFileselector.cpp",
            "profiler/src/profiler/TracyFilesystem.cpp",
            "profiler/src/profiler/TracyImGui.cpp",
            "profiler/src/profiler/TracyMicroArchitecture.cpp",
            "profiler/src/profiler/TracyMouse.cpp",
            "profiler/src/profiler/TracyProtoHistory.cpp",
            "profiler/src/profiler/TracySourceContents.cpp",
            "profiler/src/profiler/TracySourceTokenizer.cpp",
            "profiler/src/profiler/TracySourceView.cpp",
            "profiler/src/profiler/TracyStorage.cpp",
            "profiler/src/profiler/TracyTexture.cpp",
            "profiler/src/profiler/TracyTimelineController.cpp",
            "profiler/src/profiler/TracyTimelineItem.cpp",
            "profiler/src/profiler/TracyTimelineItemCpuData.cpp",
            "profiler/src/profiler/TracyTimelineItemGpu.cpp",
            "profiler/src/profiler/TracyTimelineItemPlot.cpp",
            "profiler/src/profiler/TracyTimelineItemThread.cpp",
            "profiler/src/profiler/TracyUserData.cpp",
            "profiler/src/profiler/TracyUtility.cpp",
            "profiler/src/profiler/TracyView.cpp",
            "profiler/src/profiler/TracyView_Annotations.cpp",
            "profiler/src/profiler/TracyView_Callstack.cpp",
            "profiler/src/profiler/TracyView_Compare.cpp",
            "profiler/src/profiler/TracyView_ConnectionState.cpp",
            "profiler/src/profiler/TracyView_ContextSwitch.cpp",
            "profiler/src/profiler/TracyView_CpuData.cpp",
            "profiler/src/profiler/TracyView_FindZone.cpp",
            "profiler/src/profiler/TracyView_FrameOverview.cpp",
            "profiler/src/profiler/TracyView_FrameTimeline.cpp",
            "profiler/src/profiler/TracyView_FrameTree.cpp",
            "profiler/src/profiler/TracyView_GpuTimeline.cpp",
            "profiler/src/profiler/TracyView_Locks.cpp",
            "profiler/src/profiler/TracyView_Memory.cpp",
            "profiler/src/profiler/TracyView_Messages.cpp",
            "profiler/src/profiler/TracyView_Navigation.cpp",
            "profiler/src/profiler/TracyView_NotificationArea.cpp",
            "profiler/src/profiler/TracyView_Options.cpp",
            "profiler/src/profiler/TracyView_Playback.cpp",
            "profiler/src/profiler/TracyView_Plots.cpp",
            "profiler/src/profiler/TracyView_Ranges.cpp",
            "profiler/src/profiler/TracyView_Samples.cpp",
            "profiler/src/profiler/TracyView_Statistics.cpp",
            "profiler/src/profiler/TracyView_Timeline.cpp",
            "profiler/src/profiler/TracyView_TraceInfo.cpp",
            "profiler/src/profiler/TracyView_Utility.cpp",
            "profiler/src/profiler/TracyView_ZoneInfo.cpp",
            "profiler/src/profiler/TracyView_ZoneTimeline.cpp",
            "profiler/src/profiler/TracyWeb.cpp",

            "profiler/src/imgui/imgui_impl_opengl3.cpp",
            "profiler/src/ConnectionHistory.cpp",
            "profiler/src/Filters.cpp",
            "profiler/src/Fonts.cpp",
            "profiler/src/HttpRequest.cpp",
            "profiler/src/ImGuiContext.cpp",
            "profiler/src/ini.c",
            "profiler/src/IsElevated.cpp",
            "profiler/src/main.cpp",
            "profiler/src/ResolvService.cpp",
            "profiler/src/RunQueue.cpp",
            "profiler/src/WindowPosition.cpp",
            "profiler/src/winmain.cpp",
            "profiler/src/winmainArchDiscovery.cpp",

            "server/TracyMemory.cpp",
            "server/TracyMmap.cpp",
            "server/TracyPrint.cpp",
            "server/TracySysUtil.cpp",
            "server/TracyTaskDispatch.cpp",
            "server/TracyTextureCompression.cpp",
            "server/TracyThreadCompress.cpp",
            "server/TracyWorker.cpp",

            "profiler/src/BackendGlfw.cpp",
            "profiler/src/imgui/imgui_impl_glfw.cpp",

            // "public/client/TracyAlloc.cpp",
            // "public/client/TracyCallstack.cpp",
            // "public/client/TracyDxt1.cpp",
            // "public/client/TracyOverride.cpp",
            // "public/client/TracyProfiler.cpp",
            // "public/client/tracy_rpmalloc.cpp",
            // "public/client/TracySysPower.cpp",
            // "public/client/TracySysTime.cpp",
            // "public/client/TracySysTrace.cpp",
            "public/common/tracy_lz4.cpp",
            "public/common/tracy_lz4hc.cpp",
            "public/common/TracySocket.cpp",
            "public/common/TracyStackFrames.cpp",
            // "public/common/TracySystem.cpp",
            "public/libbacktrace/alloc.cpp",
            "public/libbacktrace/dwarf.cpp",
            // "public/libbacktrace/elf.cpp",
            "public/libbacktrace/fileline.cpp",
            "public/libbacktrace/macho.cpp",
            "public/libbacktrace/mmapio.cpp",
            "public/libbacktrace/posix.cpp",
            "public/libbacktrace/sort.cpp",
            "public/libbacktrace/state.cpp",
            "public/TracyClient.cpp",
            "nfd/nfd_portal.cpp",

            "imgui/imgui.cpp",
            "imgui/imgui_demo.cpp",
            "imgui/imgui_draw.cpp",
            "imgui/imgui_tables.cpp",
            "imgui/imgui_widgets.cpp",
        },
        .flags = &[_][]const u8{
            "-fno-sanitize=undefined",
            "-fexperimental-library",
        },
    });
    tracy_exe.addIncludePath(tracy_dep.path("."));
    tracy_exe.addIncludePath(tracy_dep.path("imgui"));
    tracy_exe.addIncludePath(tracy_dep.path("profiler"));
    tracy_exe.addIncludePath(tracy_dep.path("server"));
    tracy_exe.addIncludePath(tracy_dep.path("tracy"));
    tracy_exe.addIncludePath(tracy_dep.path(""));
    tracy_exe.addIncludePath(tracy_dep.path("common"));
    tracy_exe.linkLibC();
    tracy_exe.linkLibCpp();
    b.installArtifact(tracy_exe);
}
