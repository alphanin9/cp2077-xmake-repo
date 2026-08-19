# cp2077-xmake-repo

An [xmake](https://xmake.io) package repository for Cyberpunk 2077 modding libraries, so a
RED4ext plugin can declare its dependencies instead of vendoring them as git submodules.

Follows the [xmake-repo](https://github.com/xmake-io/xmake-repo) layout.

## Usage

Add the repository and require what you need:

```lua
add_repositories("cp2077-repo https://gitlab.com/alphanin9/cp2077-xmake-repo.git")
add_requires("red4ext-sdk", "red-lib")

target("MyMod")
    set_kind("shared")
    set_arch("x64")
    set_languages("cxx20")
    add_files("src/*.cpp")
    add_packages("red4ext-sdk", "red-lib")
```

See [examples/](examples) for four complete plugins, from a bare `red4ext-sdk` hello world
to one built on SharedPunk's reversing infrastructure.

## Packages

| Package | Upstream | Notes |
| --- | --- | --- |
| `red4ext-sdk` | [wopss/RED4ext.SDK](https://github.com/wopss/RED4ext.SDK) | Header-only by default. Pass `{configs = {headeronly = false}}` for the static library. |
| `red-lib` | [psiberx/cp2077-red-lib](https://github.com/psiberx/cp2077-red-lib) | Header-only. Pulls in `red4ext-sdk`. |
| `archive-xl` | [psiberx/cp2077-archive-xl](https://github.com/psiberx/cp2077-archive-xl) | The `support/` registration header only, not the mod. |
| `tweak-xl` | [psiberx/cp2077-tweak-xl](https://github.com/psiberx/cp2077-tweak-xl) | The `support/` registration header only, not the mod. |
| `sharedpunk` | [alphanin9/sharedpunk](https://github.com/alphanin9/SharedPunk) | Static library. Pulls in `red4ext-sdk`, `red-lib` and `safetyhook`. |

`archive-xl` and `tweak-xl` provide the client-side API a plugin uses to register its own
archives and tweaks at runtime. ArchiveXL and TweakXL still have to be installed in the
game for those registrations to do anything.

Everything here is `windows` / `x64` only, and built against the `MD` runtime, matching the
game and RED4ext.

### Deviations from upstream

Two packages patch their sources at install time. Both are commented in the package files:

- `red4ext-sdk` also installs `vendor/D3D12MemAlloc/D3D12MemAlloc.h`, which upstream's
  CMake install rules leave out even though `RED4ext/GpuApi/*.hpp` includes it.
- `archive-xl` and `tweak-xl` hoist `<RED4ext/RED4ext.hpp>` to the top of their support
  header. As shipped it is not self-contained — it reaches `<minwindef.h>` before
  `<Windows.h>`, and `<RED4ext/RTTISystem.hpp>` before the umbrella header that orders the
  SDK's internal dependencies. Upstream gets away with it because consumers include the
  SDK from a pch first.

## Contributing

Add a package under `packages/<first-letter>/<name>/xmake.lua`, then test it:

```sh
xmake l ./scripts/test.lua -p windows -a x64 <name>
```

Omit the name to test every declared version of every package in the repository,
which is what the Packages workflow does. The Examples workflow builds each example
against the checkout, so a package change is exercised end to end.

To do the same locally:

```sh
cd examples/hello-world && xmake f -p windows -a x64 -m release -y && xmake
```

## Mirrors

This repository lives on both [GitLab](https://gitlab.com/alphanin9/cp2077-xmake-repo)
and [GitHub](https://github.com/alphanin9/cp2077-xmake-repo). `add_repositories` takes a
single url with no fallback, so the snippets above name the GitLab one; either works.
