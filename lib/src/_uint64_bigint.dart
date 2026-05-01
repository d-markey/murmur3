import 'dart:typed_data';

import '_helpers.dart';
import 'uint.dart' show IUint64;

/// 64-bit arithmetic based on a [BigInt] value.
// ignore: camel_case_types
class Uint64_BigInt implements IUint64 {
  static final _loMask = BigInt.parse('0x00000000FFFFFFFF');
  static final _hiMask = BigInt.parse('0xFFFFFFFF00000000');

  Uint64_BigInt(Object? value) : _value = toBigInt(value);

  @override
  BigInt get value => _value;
  BigInt _value;

  @override
  int loadLEBytes(ByteData bytes, int offset, {int fromByte = 0}) {
    final len = bytes.lengthInBytes;
    if (fromByte == 0 && len - offset >= 8) {
      final lo = bytes.getUint32(offset, Endian.little);
      final hi = bytes.getUint32(offset + 4, Endian.little);
      _value = (BigInt.from(hi) << 32) | BigInt.from(lo);
      return 8;
    }

    var count = fromByte * 8;
    var lo = (fromByte == 0) ? 0 : (_value & _loMask).toInt();
    var hi = (fromByte == 0) ? 0 : ((_value & _hiMask) >> 32).toInt();
    while (count < 32 && offset < len) {
      lo |= bytes.getUint8(offset) << count;
      count += 8;
      offset++;
    }
    while (count < 64 && offset < len) {
      hi |= bytes.getUint8(offset) << (count - 32);
      count += 8;
      offset++;
    }
    _value = (BigInt.from(hi) << 32) | BigInt.from(lo);
    return count ~/ 8 - fromByte;
  }

  @override
  void add(IUint64 other) => _value = clamp64(_value + other.value);

  @override
  void mul(IUint64 other) => _value = clamp64(_value * other.value);

  @override
  void rotl(int n) => _value = clamp64(_value << n | (_value >> (64 - n)));

  @override
  void xor(IUint64 other) => _value ^= other.value;

  @override
  void shl(int n) => _value = clamp64(_value << n);

  @override
  void xshr(int n) => _value ^= (_value.toUnsigned(64) >> n);
}
