# archive-tweak-registration

A plugin that ships its own assets and tweaks inside its plugin folder, instead of
scattering them into `archive/pc/mod/` and `r6/tweaks/`.

```sh
xmake f -p windows -a x64 -m release -y
xmake
```

`xmake.lua` has an `after_build` step that assembles the game layout under `dist/`:

```
dist/red4ext/plugins/ArchiveTweakRegistration/
├── ArchiveTweakRegistration.dll
├── archives/
│   ├── example.archive        <- your built .archive goes here (not checked in)
│   └── example.archive.xl
└── tweaks/
    └── example.yaml
```

Copy `dist/` into your Cyberpunk 2077 install directory.

## What it covers

- `ArchiveXL::RegisterArchives` and `TweakXL::RegisterTweaks`, both taking the plugin's
  `PluginHandle` so relative paths resolve against the plugin's own directory
  (`PluginHandle` is an `HMODULE`).
- Calling them straight from `Main`. The support headers queue paths and flush them from
  an RTTI post-register callback if ArchiveXL / TweakXL have not initialised yet.
- The return value means "the path exists", not "ArchiveXL is installed". If neither mod
  is present the calls succeed and quietly do nothing.

ArchiveXL and TweakXL must be installed for any of this to have an effect — the
`archive-xl` and `tweak-xl` packages only provide the client-side registration headers,
not the mods themselves.
