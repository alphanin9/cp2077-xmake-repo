package("red-lib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/psiberx/cp2077-red-lib")
    set_description("Header-only library to help create RED4ext plugins.")
    set_license("MIT")

    add_urls("https://github.com/psiberx/cp2077-red-lib.git")

    add_versions("2026.08.09", "6822105d15d1b8bd1e6aae5e57827835e585cfe8")
    add_versions("2026.06.10", "009d404d0ed96c7bfce8e937cc1cc97cc13b1c5f")
    add_versions("2026.04.13", "120c46c3c4c91c70b4c23002bf77cc6dd29832b1")

    add_deps("red4ext-sdk")

    -- RedLib pulls in <Windows.h> through the SDK and then uses std::min/std::max.
    add_defines("NOMINMAX")

    on_install("windows|x64", function (package)
        -- Upstream's CMakeLists.txt only declares an INTERFACE target, it has no install
        -- rules at all, so the headers are copied by hand. vendor/ is a second include
        -- root: RedLib.hpp does `#include <nameof/nameof.hpp>`.
        os.cp("include", package:installdir())
        os.cp("vendor/nameof", package:installdir("include"))
    end)

    on_test("windows|x64", function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto name = Red::GetTypeName<Red::CName>();
                (void)name;
            }
        ]]}, {configs = {languages = "cxx20"}, includes = "RedLib.hpp"}))
    end)
