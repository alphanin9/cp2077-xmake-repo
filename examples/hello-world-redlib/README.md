# hello-world-redlib

The same plugin as `hello-world`, written with RedLib's declarative RTTI.

```sh
xmake f -p windows -a x64 -m release -y
xmake
```

## What it covers

- `RTTI_DEFINE_CLASS` / `RTTI_DEFINE_GLOBALS` — RedLib generates the stack-frame
  marshalling from the C++ signature, so methods are written as ordinary functions taking
  ordinary arguments.
- `RTTI_IMPL_TYPEINFO` and `RTTI_IMPL_ALLOCATOR`, which a native class needs to be
  constructible by the game.
- `Red::TypeInfoRegistrar::RegisterDiscovered()` in `Main`. Every `RTTI_DEFINE_*` in the
  DLL registers itself into a static list; without this call none of them are applied.
- `Red::Log::Channel`, which routes through the game's own `LogChannel`.

## Using it from redscript

```swift
native class Greeter {
    native func Greet(name: String) -> String;
    native func GetGreetCount() -> Uint32;
}

native func HelloWorldRedLib_Shout(name: String) -> String;
```
