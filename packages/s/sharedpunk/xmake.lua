package("sharedpunk")
    set_homepage("https://github.com/alphanin9/SharedPunk")
    set_description("Core utilities and reverse engineered game data for Cyberpunk 2077 mods built on RED4ext.SDK and RedLib.")
    set_license("MIT")

    add_urls("https://github.com/alphanin9/SharedPunk.git")

    add_versions("2026.08.19", "327c29f6d1d7864231700e64e2e09108cb1b3385")

    -- SharedPunk's own xmake.lua requires these three and adds this repository to find
    -- them, so they resolve to the same packages installed here.
    add_deps("red4ext-sdk", "red-lib", "safetyhook")

    -- Mirrors the target's add_defines. WIN32_LEAN_AND_MEAN in particular has to match
    -- across the boundary: it changes what <Windows.h> declares, and the public headers
    -- are compiled again in the consumer.
    add_defines("WINVER=0x0601", "WIN32_LEAN_AND_MEAN", "NOMINMAX")

    add_syslinks("Version", "User32")

    on_install("windows|x64", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test("windows|x64", function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto system = shared::raw::Localization::LocalizationSystem::GetInstance();
                (void)system;
            }
        ]]}, {configs = {languages = "cxxlatest"},
              includes = {"RED4ext/RED4ext.hpp",
                          "Shared/Raw/LocalizationSystem/LocalizationSystem.hpp",
                          -- reaches safetyhook.hpp via Impl/Hooks/Driver/HookingDriver.hpp,
                          -- so this also checks that safetyhook is exported to consumers
                          "Shared/Hooks/HookManager.hpp"}}))
    end)
