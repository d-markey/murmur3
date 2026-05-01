## 3.0.0

- Remove support for Dart 2.
- Implement native `64-bit` int for VM and Web Assembly.
- Removed `static` methods from `MurmurHashV3` class. Implementations of `IUint32` and `IUint64` are now provided via the constructor instead of being set via static members.
- Removed alias `Uint32_int_xplat`.
- The default `murmur3` instance exposed in `lib\murmur3.dart` uses `Uint32_int_48bit_mul` and `Uint64_int` which are cross-platform (VM/JS/WASM).
- Reworked unit tests.

## 2.1.0

- Enable support for Dart 3.

## 2.0.0

- Breaking change for murmur 3f (128 bits) - make the seed a BigInt (clamped to 128 bits).

## 1.0.0

- Initial version.
