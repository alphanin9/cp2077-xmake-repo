package("tweak-xl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/psiberx/cp2077-tweak-xl")
    set_description("TweakXL support API: lets a RED4ext plugin register .yaml / .tweak files at runtime.")
    set_license("MIT")

    -- This packages support/red4ext/ only. It does not build the TweakXL mod itself --
    -- users still need TweakXL installed in their game for the registration calls to do anything.
    add_urls("https://github.com/psiberx/cp2077-tweak-xl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/psiberx/cp2077-tweak-xl.git",
             {version = function (version) return (tostring(version):gsub("%-macos%.%d+$", "")) end})

    if is_plat("macosx") then
        -- Same source as v1.11.4 with the macosx patch. The suffix keeps the patched package apart from cached
        -- unpatched ones, and it is the only version offered here so dependents resolve to it.
        add_versions("v1.11.4-macos.2", "38b414622d68022620910bb56656afe183933e9dff987b1090e7007e5b526a88")
    else
        add_versions("v1.11.4", "38b414622d68022620910bb56656afe183933e9dff987b1090e7007e5b526a88")
        add_versions("v1.11.3", "2cdf7e999ec3e99c071b06204c37edf62d53d7060499ad3d32cc3e6dad328b60")
        add_versions("v1.11.2", "10e8682a3e36b6774e2a66ac3760c2e2b74b6122b5dfe098c88a859ccc2c56a6")
    end

    add_deps("red4ext-sdk")

    -- Same header change as archive-xl, for TweakXL.hpp. Pending in psiberx/cp2077-tweak-xl.
    if is_plat("macosx") then
        add_patches("v1.11.4-macos.2", path.join(os.scriptdir(), "patches", "macos-support-header.patch"),
                    "e06e0722d26592b52c0d0008994518cffeb9a46e4210f9840d93a876f35dfc3c")
    end

    on_install("windows|x64", "macosx|arm64", function (package)
        -- The header as shipped is not self-contained: it starts with <libloaderapi.h> /
        -- <minwindef.h> (which need <Windows.h> first for _AMD64_, else winnt.h errors with
        -- "No Target Architecture") and then pulls <RED4ext/RTTISystem.hpp>, which on its own
        -- trips over NativeTypes.hpp referencing CRTTISystem before it is declared. Upstream
        -- gets away with it because every consumer includes the SDK umbrella header from a
        -- pch first. Hoisting that umbrella here fixes both, and costs nothing: RTTISystem.hpp
        -- already drags in most of the SDK anyway.
        if package:is_plat("windows") then
            io.replace("support/red4ext/TweakXL.hpp",
                       "#include <libloaderapi.h>",
                       "#include <RED4ext/RED4ext.hpp>\n\n#include <libloaderapi.h>",
                       {plain = true})
        else
            io.replace("support/red4ext/TweakXL.hpp",
                       "#include <filesystem>",
                       "#include <RED4ext/RED4ext.hpp>\n\n#include <filesystem>",
                       {plain = true})
        end

        os.cp("support/red4ext/TweakXL.hpp", package:installdir("include/RED4ext"))
    end)

    on_test("windows|x64", function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                TweakXL::RegisterTweaks("tweaks");
            }
        ]]}, {configs = {languages = "cxx20"}, includes = "RED4ext/TweakXL.hpp"}))
    end)
