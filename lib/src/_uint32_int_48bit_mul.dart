import 'uint.dart' show IUint32;

/// 32-bit arithmetic based on a 32-bit int value. This implementation uses
/// multiplication on 16-bit numbers for compatibility with browser platforms
/// where integer values are safe up to `pow(2, 53)` only.
// ignore: camel_case_types
class Uint32_int_48bit_mul implements IUint32 {
  static const _mask16 = 0x0000FFFF;
  static const _mask32 = 0xFFFFFFFF;

  static int _clamp(int n) => n & _mask32;

  Uint32_int_48bit_mul(int num) : _num = _clamp(num);

  @override
  int get value => _num;
  int _num;

  @override
  int loadLEBytes(List<int> bytes, int offset, {int fromByte = 0}) {
    var idx = offset, len = bytes.length, count = 0;
    if (fromByte == 0) {
      _num = 0;
    }
    var n = fromByte * 8;
    while (idx < len && n < 32) {
      _num |= bytes[idx] << n;
      count++;
      idx++;
      n += 8;
    }
    return count;
  }

  @override
  void add(IUint32 other) => _num = _clamp(_num + other.value);

  @override
  void mul(IUint32 other) {
    final n = other.value;

    // 32-bit multiplication
    // on browser platforms, ints are safe up to 53-bit
    // decomposing multiplication as 32-bit * 16-bit yielding 48-bits
    final lo = (_num * (n & _mask16)) & _mask32;
    final hi = (_num * (n >> 16)) & _mask16;

    _num = _clamp(lo + (hi << 16));
  }

  @override
  void rotl(int n) => _num = _clamp(_num << n) | (_num >> (32 - n));

  @override
  void shl(int n) => _num = _clamp(_num << n);

  @override
  void xor(IUint32 other) => _num ^= other.value;

  @override
  void xshr(int n) => _num ^= (_num >> n);
}

/// Type definition for platform-specific implementation
// ignore: camel_case_types
typedef Uint32_int_xplat = Uint32_int_48bit_mul;
