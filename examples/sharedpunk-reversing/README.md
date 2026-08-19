# sharedpunk-reversing

A plugin built on SharedPunk's reverse engineering infrastructure.

```sh
xmake f -p windows -a x64 -m release -y
xmake
```

Note the `set_languages("c++latest")` — SharedPunk is built that way, and SafetyHook
underneath it needs C++23 or newer.

## What it covers

- `util::RawFunc<AddressHash, Signature>` — game functions described by an address hash
  resolved through RED4ext's address library at first use, rather than a hardcoded offset,
  so the definitions survive game patches.
- `shared::hook::HookAfter<Target>` — hooking one of those definitions directly. The
  target is the `RawFunc` itself; SafetyHook trampolines are managed underneath.
- Calling a reversed function through SharedPunk's wrapper
  (`LocalizationSystem::GetOnscreen`) and exposing the result to redscript with RedLib.

## Using it from redscript

```swift
native func SharedPunkReversing_Onscreen(key: String) -> String;
```
