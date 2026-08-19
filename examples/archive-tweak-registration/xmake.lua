-- RED4ext plugin that ships its own .archive / .xl / .yaml files next to the DLL and
-- registers them at runtime through the ArchiveXL and TweakXL support APIs. This keeps
-- everything under red4ext/plugins/<YourMod>/ instead of scattering files into
-- archive/pc/mod/ and r6/tweaks/.
--
-- Copying this out of the repo? Replace the add_repositories() line below with:
--   add_repositories("cp2077-repo https://github.com/alphanin9/cp2077-xmake-repo.git")
add_repositories("cp2077-repo " .. path.absolute(path.join(os.scriptdir(), "..", "..")))

set_project("ArchiveTweakRegistration")
set_arch("x64")
set_languages("cxx20")
add_rules("mode.debug", "mode.release")

add_requires("red4ext-sdk", "archive-xl", "tweak-xl")

target("ArchiveTweakRegistration")
    set_kind("shared")
    set_filename("ArchiveTweakRegistration.dll")
    set_runtimes(is_mode("debug") and "MDd" or "MD")
    add_files("src/*.cpp")
    add_packages("red4ext-sdk", "archive-xl", "tweak-xl")
    add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX")

    -- Assemble the layout the game expects, so dist/ can be dropped straight into the
    -- Cyberpunk 2077 install directory.
    after_build(function (target)
        local plugindir = path.join(os.projectdir(), "dist", "red4ext", "plugins", target:name())

        os.mkdir(plugindir)
        os.cp(target:targetfile(), plugindir)
        os.cp(path.join(os.projectdir(), "mod", "*"), plugindir)

        cprint("${color.success}deployed to %s", plugindir)
    end)
