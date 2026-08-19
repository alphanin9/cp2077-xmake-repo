-- RED4ext plugin using RedLib's declarative RTTI instead of hand-rolled registration.
--
-- Copying this out of the repo? Replace the add_repositories() line below with:
--   add_repositories("cp2077-repo https://github.com/alphanin9/cp2077-xmake-repo.git")
add_repositories("cp2077-repo " .. path.absolute(path.join(os.scriptdir(), "..", "..")))

set_project("HelloWorldRedLib")
set_arch("x64")
set_languages("cxx20")
add_rules("mode.debug", "mode.release")

-- red-lib pulls in red4ext-sdk itself, but naming both keeps the intent obvious.
add_requires("red4ext-sdk", "red-lib")

target("HelloWorldRedLib")
    set_kind("shared")
    set_filename("HelloWorldRedLib.dll")
    set_runtimes(is_mode("debug") and "MDd" or "MD")
    add_files("src/*.cpp")
    add_packages("red4ext-sdk", "red-lib")
    add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX")
