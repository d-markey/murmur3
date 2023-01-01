export '_uint32_int_48bit_mul.dart' show Uint32_int_48bit_mul;
export '_uint32_int_64bit_mul.dart' show Uint32_int_64bit_mul;
export '_uint32_int_64bit_mul.dart'
    if (dart.library.js) '_uint32_int_48bit_mul.dart' show Uint32_int_xplat;
export '_uint64_bigint.dart';
export '_uint64_int.dart';

/// Contract for 32-bit arithmetic used in MurmurHash v3 - 32-bit.
abstract class IUint32 extends IUint<IUint32, int> {}

/// Contract for 64-bit arithmetic used in MurmurHash v3 - 128-bit x64.
abstract class IUint64 extends IUint<IUint64, BigInt> {}

/// Contract for arithmetic used in MurmurHash v3.
abstract class IUint<T, V> {
  /// Returns the current value stored in this instance.
  V get value;

  /// Loads bytes into the internal register (little-endian). Returns the number
  /// of bytes that have been loaded.
  int loadLEBytes(List<int> bytes, int offset, {int fromByte = 0});

  /// In-place addition. The value stored in this instance is replaced with the
  /// result.
  void add(T other);

  /// In-place multiplication. The value stored in this instance is replaced with
  /// the result.
  void mul(T other);

  /// In-place left-rotation. The value stored in this instance is replaced with
  /// the result.
  void rotl(int n);

  /// In-place left-shift operation. The value stored in this instance is replaced
  /// with the result.
  void shl(int n);

  /// In-place XOR operation. The value stored in this instance is replaced with
  /// the result.
  void xor(T other);

  /// In-place XOR operation with current value right-shifted by [n] bits. The
  /// value stored in this instance is replaced with the result.
  void xshr(int n);
}
