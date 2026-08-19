# hello-world

The smallest useful RED4ext plugin: `red4ext-sdk` only.

```sh
xmake f -p windows -a x64 -m release -y
xmake
```

## What it covers

- The three exports every plugin must provide — `Supports`, `Query`, `Main`.
- Registering a global function from the RTTI post-register callback. Doing this from
  `Main` does not work; the RTTI system is not populated yet at load time.
- Reading arguments off a `CStackFrame` by hand, including the `aFrame->code++` that skips
  the `ParamEnd` opcode. Forgetting it corrupts the caller's stack.

## Using it from redscript

```swift
native func HelloWorld_Greet(name: String) -> String;
```

`hello-world-redlib` does the same thing without the manual marshalling.
