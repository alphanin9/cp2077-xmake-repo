-- RED4ext plugin using SharedPunk's reverse engineering infrastructure: address-hash
-- based function pointers that survive game updates, and its SafetyHook-backed hooking.
--
-- Copying this out of the repo? Replace the add_repositories() line below with:
--   add_repositories("cp2077-repo https://gitlab.com/alphanin9/cp2077-xmake-repo.git")
add_repositories("cp2077-repo " .. path.absolute(path.join(os.scriptdir(), "..", "..")))

set_project("SharedPunkReversing")
set_arch("x64")
-- SharedPunk itself is built as c++latest; SafetyHook needs C++23 or newer.
set_languages("c++latest")
add_rules("mode.debug", "mode.release")

-- sharedpunk brings red4ext-sdk, red-lib and safetyhook along with it.
add_requires("sharedpunk")

target("SharedPunkReversing")
    set_kind("shared")
    set_filename("SharedPunkReversing.dll")
    set_runtimes(is_mode("debug") and "MDd" or "MD")
    add_files("src/*.cpp")
    add_packages("sharedpunk")
    add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX")
