import 'dart:typed_data';

import '_helpers.dart';
import 'uint.dart' show IUint32;

/// 32-bit arithmetic based on a 32-bit int value. This implementation uses
/// multiplication on 16-bit numbers for compatibility with browser platforms
/// where integer values are safe up to `pow(2, 53)` only.
// ignore: camel_case_types
class Uint32_int_48bit_mul implements IUint32 {
  static const _mask16 = 0x0000FFFF;

  Uint32_int_48bit_mul(int value) : _value = clamp32(value);

  @override
  int get value => _value;
  int _value;

  @override
  int loadLEBytes(ByteData bytes, int offset, {int fromByte = 0}) {
    final len = bytes.lengthInBytes;
    if (fromByte == 0 && len - offset >= 4) {
      _value = bytes.getUint32(offset, Endian.little);
      return 4;
    }

    var count = fromByte * 8;
    var value = (fromByte == 0) ? 0 : _value;
    while (count < 32 && offset < len) {
      value |= bytes.getUint8(offset) << count;
      count += 8;
      offset++;
    }
    _value = value;
    return count ~/ 8 - fromByte;
  }

  @override
  void add(IUint32 other) => _value = clamp32(_value + other.value);

  @override
  void mul(IUint32 other) {
    final n = other.value;

    // 32-bit multiplication
    // on browser platforms, ints are safe up to 53-bit
    // decomposing multiplication as 32-bit * 16-bit yielding 48-bits
    final lo = (_value * (n & _mask16)) & mask32;
    final hi = (_value * (n >> 16)) & _mask16;

    _value = clamp32(lo + (hi << 16));
  }

  @override
  void rotl(int n) => _value = clamp32(_value << n) | (_value >> (32 - n));

  @override
  void shl(int n) => _value = clamp32(_value << n);

  @override
  void xor(IUint32 other) => _value ^= other.value;

  @override
  void xshr(int n) => _value ^= (_value >> n);
}
