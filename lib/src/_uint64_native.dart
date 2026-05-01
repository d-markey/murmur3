import 'dart:typed_data';

import '_helpers.dart';
import 'uint.dart';

/// 64-bit arithmetic based on a native 64-bit int.
// ignore: camel_case_types
class Uint64_native implements IUint64 {
  Uint64_native(Object? value) {
    if ($vmOrWasm) {
      _value = switch (value) {
        int() => value,
        Uint64_native() => value._value,
        _ => toBigInt(value).toSigned(64).toInt(),
      };
    } else {
      unsupported64bit();
    }
  }

  int _value = 0;

  @override
  BigInt get value =>
      $vmOrWasm ? BigInt.from(_value).toUnsigned(64) : unsupported64bit();

  @override
  int loadLEBytes(ByteData bytes, int offset, {int fromByte = 0}) {
    if ($vmOrWasm) {
      final len = bytes.lengthInBytes;
      if (fromByte == 0 && len - offset >= 8) {
        _value = bytes.getUint32(offset, Endian.little) |
            (bytes.getUint32(offset + 4, Endian.little) << 32);
        return 8;
      }

      var count = fromByte * 8;
      var value = (fromByte == 0) ? 0 : _value;
      while (count < 64 && offset < len) {
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
  void add(IUint64 other) {
    if ($vmOrWasm) {
      _value += (other as Uint64_native)._value;
    } else {
      unsupported64bit();
    }
  }

  @override
  void mul(IUint64 other) {
    if ($vmOrWasm) {
      final b = (other as Uint64_native)._value;
      final aL = _value & mask32;
      final aH = _value >>> 32;
      final bL = b & mask32;
      final bH = b >>> 32;

      // (aH*2^32 + aL) * (bH*2^32 + bL) = (aH*bL + aL*bH) << 32 + aL*bL
      _value = (aL * bL) + (((aH * bL + aL * bH) & mask32) << 32);
    } else {
      unsupported64bit();
    }
  }

  @override
  void rotl(int n) {
    if ($vmOrWasm) {
      n %= 64;
      if (n == 0) return;
      _value = (_value << n) | (_value >>> (64 - n));
    } else {
      unsupported64bit();
    }
  }

  @override
  void shl(int n) {
    if ($vmOrWasm) {
      if (n >= 64) {
        _value = 0;
      } else {
        _value <<= n;
      }
    } else {
      unsupported64bit();
    }
  }

  @override
  void xor(IUint64 other) {
    if ($vmOrWasm) {
      _value ^= (other as Uint64_native)._value;
    } else {
      unsupported64bit();
    }
  }

  @override
  void xshr(int n) {
    if ($vmOrWasm) {
      if (n >= 64) {
        _value ^= 0;
      } else {
        _value ^= (_value >>> n);
      }
    } else {
      unsupported64bit();
    }
  }
}
