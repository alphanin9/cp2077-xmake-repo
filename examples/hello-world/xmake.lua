-- Minimal RED4ext plugin built against the packages in this repo.
--
-- Copying this out of the repo? Replace the add_repositories() line below with:
--   add_repositories("cp2077-repo https://gitlab.com/alphanin9/cp2077-xmake-repo.git")
add_repositories("cp2077-repo " .. path.absolute(path.join(os.scriptdir(), "..", "..")))

set_project("HelloWorld")
set_arch("x64")
set_languages("cxx20")
add_rules("mode.debug", "mode.release")

add_requires("red4ext-sdk")

target("HelloWorld")
    set_kind("shared")
    -- RED4ext loads red4ext/plugins/<AnyName>/<AnyName>.dll, so the file name matters.
    set_filename("HelloWorld.dll")
    set_runtimes(is_mode("debug") and "MDd" or "MD")
    add_files("src/*.cpp")
    add_packages("red4ext-sdk")
    add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX")
