import 'dart:typed_data';

import 'package:murmur3/src/_helpers.dart';

import 'uint.dart' show IUint32;

/// 32-bit arithmetic based on a 32-bit int value. This implementation uses
/// multiplication on 64-bit numbers and is not compatible with browser platforms
/// where integer values are safe up to `pow(2, 53)` only.
// ignore: camel_case_types
class Uint32_int_64bit_mul implements IUint32 {
  Uint32_int_64bit_mul(int value) {
    if ($vmOrWasm) {
      _value = clamp32(value);
    } else {
      unsupported64bit();
    }
  }

  @override
  int get value => $vmOrWasm ? _value : unsupported64bit();
  int _value = 0;

  @override
  int loadLEBytes(ByteData bytes, int offset, {int fromByte = 0}) {
    if ($vmOrWasm) {
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
    } else {
      unsupported64bit();
    }
  }

  @override
  void add(IUint32 other) {
    if ($vmOrWasm) {
      _value = clamp32(_value + other.value);
    } else {
      unsupported64bit();
    }
  }

  @override
  // requires 64-bit arithmetic
  void mul(IUint32 other) {
    if ($vmOrWasm) {
      _value = clamp32(_value * other.value);
    } else {
      unsupported64bit();
    }
  }

  @override
  void rotl(int n) {
    if ($vmOrWasm) {
      _value = clamp32(_value << n) | (_value >> (32 - n));
    } else {
      unsupported64bit();
    }
  }

  @override
  void shl(int n) {
    if ($vmOrWasm) {
      _value = clamp32(_value << n);
    } else {
      unsupported64bit();
    }
  }

  @override
  void xor(IUint32 other) {
    if ($vmOrWasm) {
      _value ^= other.value;
    } else {
      unsupported64bit();
    }
  }

  @override
  void xshr(int n) {
    if ($vmOrWasm) {
      _value ^= (_value >> n);
    } else {
      unsupported64bit();
    }
  }
}
