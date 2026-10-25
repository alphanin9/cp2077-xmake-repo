package("red4ext-sdk")
    set_homepage("https://github.com/WopsS/RED4ext.SDK")
    set_description("A library to create mods for REDengine 4 (Cyberpunk 2077), independently of RED4ext.")
    set_license("MIT")

    -- RED4ext/Scripting/Natives/Generated/** nests deep enough to blow past MAX_PATH on
    -- checkout, which fails the clone outright on a stock Windows box.
    set_policy("platform.longpaths", true)

    if is_plat("macosx") then
        -- macOS (Apple Silicon): jackmaxwil's port of the SDK, based on RED4ext.SDK 1.0. Same include/ layout.
        -- Game addresses resolve through its cyberpunk2077_addresses.json at run time, not through this package.
        add_urls("https://github.com/jackmaxwil/RED4ext.SDK-macos.git")

        add_versions("2026.10.11", "f657158c0c11248932c4a8567d800286d5e29e62")
    else
        -- Set this to your own repo when making some PR.
        add_urls("https://github.com/WopsS/RED4ext.SDK.git")

        add_versions("2026.10.24", "5246e659d783e5834cc08a90e56c8932c9ed3449")
        add_versions("2026.07.30", "ad7277714ad30d6885d7050c5ba24fa0102f6920")
        add_versions("2026.07.06", "cce6e255f5e61056e634f324a3dbdfa6da523af9")
        add_versions("2026.06.07", "109b585a956b694b859ca9e75766543be60d2051")
        add_versions("2026.05.30", "fcda519942ef74d2191accfa752bb5c423f3e953")
        add_versions("2026.03.09", "a4a781088a92a8efa890d94fde4efd8985d497c7")
    end

    -- Relocation-inl.hpp pops a MessageBoxW when an address lookup fails, so anything
    -- touching RED4ext::UniversalReloc* needs User32 -- including header-only consumers,
    -- which is most of them.
    if is_plat("windows") then
        add_syslinks("User32")
    end

    -- The SDK is consumed header-only by most of the CP2077 modding ecosystem
    -- (TweakXL, ArchiveXL, Codeware, SharedPunk, ...), so that is the default here too.
    add_configs("headeronly", {description = "Use the header-only version of the library.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("headeronly") then
            package:set("kind", "library", {headeronly = true})
        else
            -- Common.hpp keys off this to switch the *-inl.hpp bodies from `inline` to
            -- out-of-line definitions. CMake exports it as a PUBLIC define, but nothing
            -- consumes RED4extConfig.cmake here, so it has to be re-declared.
            package:add("defines", "RED4EXT_STATIC_LIB")
            package:add("deps", "cmake")
        end
    end)

    on_install("windows|x64", "macosx|arm64", function (package)
        if not package:config("headeronly") then
            local configs = {"-DRED4EXT_HEADER_ONLY=OFF", "-DRED4EXT_BUILD_EXAMPLES=OFF", "-DRED4EXT_USE_PCH=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            import("package.tools.cmake").install(package, configs)
        else
            -- include/RED4ext/Version.hpp is checked in, so header-only needs no configure step.
            os.cp("include", package:installdir())
        end

        -- RED4ext/GpuApi/*.hpp do `#include <D3D12MemAlloc.h>`, and upstream's install
        -- rules only cover include/ -- without this, anything reaching GpuApi fails to compile.
        if package:is_plat("windows") then
            os.cp("vendor/D3D12MemAlloc/D3D12MemAlloc.h", package:installdir("include"))
        end
    end)

    on_test("windows|x64", function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                RED4ext::CName name("RED4ext.SDK");
                (void)name.hash;
            }
        ]]}, {configs = {languages = "cxx20"}, includes = "RED4ext/RED4ext.hpp"}))
    end)
