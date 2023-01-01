import 'uint.dart' show IUint64;

/// 64-bit arithmetic based on a [BigInt] value.
// ignore: camel_case_types
class Uint64_BigInt implements IUint64 {
  static final _mask = BigInt.parse('0xFFFFFFFFFFFFFFFF');
  static final _loMask = BigInt.parse('0x00000000FFFFFFFF');
  static final _hiMask = BigInt.parse('0xFFFFFFFF00000000');

  static BigInt _clamp(BigInt n) =>
      (BigInt.zero <= n && n <= _mask) ? n : (n & _mask);

  Uint64_BigInt(dynamic num)
      : _num = (num is BigInt)
            ? num
            : _clamp((num is String) ? BigInt.parse(num) : BigInt.from(num));

  @override
  BigInt get value => _num;
  BigInt _num;

  @override
  int loadLEBytes(List<int> bytes, int offset, {int fromByte = 0}) {
    var idx = offset, len = bytes.length, count = 0;
    int lo, hi;
    if (fromByte == 0) {
      lo = 0;
      hi = 0;
    } else {
      lo = (_num & _loMask).toInt();
      hi = ((_num & _hiMask) >> 32).toInt();
    }
    if (fromByte < 4) {
      var n = fromByte * 8;
      while (idx < len && n < 32) {
        lo |= bytes[idx] << n;
        count++;
        idx++;
        n += 8;
      }
      fromByte = 4;
    }
    if (fromByte >= 4) {
      var n = (fromByte - 4) * 8;
      while (idx < len && n < 32) {
        hi |= bytes[idx] << n;
        count++;
        idx++;
        n += 8;
      }
    }
    _num = (BigInt.from(hi) << 32) | BigInt.from(lo);
    return count;
  }

  @override
  void add(IUint64 other) => _num = _clamp(_num + other.value);

  @override
  void mul(IUint64 other) => _num = _clamp(_num * other.value);

  @override
  void rotl(int n) => _num = _clamp(_num << n | (_num >> (64 - n)));

  @override
  void xor(IUint64 other) => _num ^= other.value;

  @override
  void shl(int n) => _num = _clamp(_num << n);

  @override
  void xshr(int n) => _num ^= (_num >> n);
}
