package("archive-xl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/psiberx/cp2077-archive-xl")
    set_description("ArchiveXL support API: lets a RED4ext plugin register .archive files and .xl scripts at runtime.")
    set_license("MIT")

    -- This packages support/red4ext/ only. It does not build the ArchiveXL mod itself --
    -- users still need ArchiveXL installed in their game for the registration calls to do anything.
    add_urls("https://github.com/psiberx/cp2077-archive-xl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/psiberx/cp2077-archive-xl.git")

    add_versions("v1.27.1", "09b38c7a2f85eba869cd7f7b964de438a6d9cf25c650b3b9bdc4d08c8909645a")
    add_versions("v1.27.0", "3f97604e54be7f96b060f99e86e9db9b6297a0dd9a13270b715c6a701b656ada")
    add_versions("v1.26.8", "b1492e8215bc6b55e8ed28fc16fa8a87a7328faf3525102d8e02df99125199a6")

    add_deps("red4ext-sdk")

    on_install("windows|x64", function (package)
        -- The header as shipped is not self-contained: it starts with <libloaderapi.h> /
        -- <minwindef.h> (which need <Windows.h> first for _AMD64_, else winnt.h errors with
        -- "No Target Architecture") and then pulls <RED4ext/RTTISystem.hpp>, which on its own
        -- trips over NativeTypes.hpp referencing CRTTISystem before it is declared. Upstream
        -- gets away with it because every consumer includes the SDK umbrella header from a
        -- pch first. Hoisting that umbrella here fixes both, and costs nothing: RTTISystem.hpp
        -- already drags in most of the SDK anyway.
        io.replace("support/red4ext/ArchiveXL.hpp",
                   "#include <libloaderapi.h>",
                   "#include <RED4ext/RED4ext.hpp>\n\n#include <libloaderapi.h>",
                   {plain = true})

        os.cp("support/red4ext/ArchiveXL.hpp", package:installdir("include/RED4ext"))
    end)

    on_test("windows|x64", function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ArchiveXL::RegisterArchives("archives");
            }
        ]]}, {configs = {languages = "cxx20"}, includes = "RED4ext/ArchiveXL.hpp"}))
    end)
