# Examples

Four RED4ext plugins, each a standalone xmake project built entirely from the packages in
this repository. Read them in order — each one adds a layer.

| Example | Packages used | Shows |
| --- | --- | --- |
| [hello-world](hello-world) | `red4ext-sdk` | The plugin entry points, and registering a global function with the raw SDK |
| [hello-world-redlib](hello-world-redlib) | `red4ext-sdk`, `red-lib` | The same idea with RedLib's declarative RTTI — no hand-written stack marshalling |
| [archive-tweak-registration](archive-tweak-registration) | `red4ext-sdk`, `archive-xl`, `tweak-xl` | Shipping `.archive` / `.yaml` files inside your plugin folder and registering them at runtime |
| [sharedpunk-reversing](sharedpunk-reversing) | `sharedpunk` | Address-hash function pointers and hooking, via SharedPunk's reversing infrastructure |

## Building

Each directory is self-contained:

```sh
cd examples/hello-world
xmake f -p windows -a x64 -m release -y
xmake
```

The output DLL lands in `build/windows/x64/release/`. Drop it into
`<game>/red4ext/plugins/<PluginName>/`.

Every example points `add_repositories` at this repository's working tree, so a local edit
to a package is picked up on the next build. When you copy an example into your own mod,
swap that line for the remote:

```lua
add_repositories("cp2077-repo https://gitlab.com/alphanin9/cp2077-xmake-repo.git")
```

## Notes

These build and link, but none of them have been run against the game — they exist to show
wiring, not to be correct mods.

`hello-world` and `hello-world-redlib` need nothing but RED4ext installed.
`archive-tweak-registration` additionally needs ArchiveXL and TweakXL present at runtime;
without them the registration calls are inert.
