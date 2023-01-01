import 'uint.dart' show IUint64;

/// 64-bit arithmetic based on two 32-bit int values.
// ignore: camel_case_types
class Uint64_int implements IUint64 {
  static const _mask32 = 0xFFFFFFFF;

  // 33rd bit set: dividing by this number is equivalent to >> 32
  static const _max32 = 0x100000000;
  // 25th bit set, dividing by this number is equivalent to >> 24
  static const _max24 = 0x01000000; // 25th bit set

  static final _maskLo32 = BigInt.parse('0x00000000FFFFFFFF');
  static final _maskHi32 = BigInt.parse('0xFFFFFFFF00000000');

  static int _lo32(BigInt n) => (n & _maskLo32).toInt();
  static int _hi32(BigInt n) => ((n & _maskHi32) >> 32).toInt();

  Uint64_int(dynamic num) {
    final n = (num is BigInt)
        ? num
        : (num is String)
            ? BigInt.parse(num)
            : BigInt.from(num);
    _lo = _lo32(n);
    _hi = _hi32(n);
  }

  @override
  BigInt get value => (BigInt.from(_hi) << 32) | (BigInt.from(_lo));
  int _lo = 0;
  int _hi = 0;

  @override
  int loadLEBytes(List<int> bytes, int offset, {int fromByte = 0}) {
    var idx = offset, len = bytes.length, count = 0;
    if (fromByte == 0) {
      _lo = 0;
      _hi = 0;
    }
    if (fromByte < 4) {
      var n = fromByte * 8;
      while (idx < len && n < 32) {
        _lo |= bytes[idx] << n;
        count++;
        idx++;
        n += 8;
      }
      fromByte = 4;
    }
    if (fromByte >= 4) {
      var n = (fromByte - 4) * 8;
      while (idx < len && n < 32) {
        _hi |= bytes[idx] << n;
        count++;
        idx++;
        n += 8;
      }
    }
    return count;
  }

  @override
  void add(IUint64 other) {
    other = other as Uint64_int;
    final slo = _lo + other._lo;
    final shi = _hi + other._hi + (slo ~/ _max32);
    _lo = slo & _mask32;
    _hi = shi & _mask32;
  }

  // decomposition of 2x 32-bit = 2x 24-bit + 1x 16-bit
  // _lo | (_hi << 32) = _lo24 | (_mid24 << 24) | (_hi16 << 48)

  // 24 lower bits
  int get _lo24 => _lo & 0x00FFFFFF;
  // 24 middle bits
  int get _mid24 => ((_hi & 0x0000FFFF) << 8) | ((_lo & 0xFF000000) >> 24);
  // 16 higher bits
  int get _hi16 => (_hi & 0xFFFF0000) >> 16;

  @override
  void mul(IUint64 other) {
    other = other as Uint64_int;

    // decomposing 2x 32-bit into 2x 24-bit + 1x 16-bit
    final llo = _lo24, lmid = _mid24, lhi = _hi16;
    final rlo = other._lo24, rmid = other._mid24, rhi = other._hi16;

    // on browser platforms, JavaScript ints are safe up to 2^53
    // as a result:
    // * multiplying 2 24-bit ints yields a safe 48-bit int
    // * adding 2 48-bit ints yields a safe 49-bit int

    // 64-bit multiplication
    //   ( lhi << 48 + lmid << 24 + llo )
    // * ( rhi << 48 + rmid << 24 + rlo )
    // = ( /* discarded */ ) << 96
    // + ( /* discarded */ ) << 72
    // + ( lhi * rlo + lmid * rmid + llo * rhi ) << 48
    // + ( lmid * rlo + llo * rmid ) << 24
    // + ( llo * rlo )

    // JavaScript enforces 32-bits for binary operations. Since we're possibly
    // working with 50/51 bits, using ">>" would result in higher bits being
    // lost. To workaround this limitation, we divide by _max24 = 0x01000000.

    // 24 * 24 --> 48 bits
    final lo = llo * rlo;
    // 24 * 24 + 24 * 24 + 48 / 24 --> <= 50 bits
    final mid = lmid * rlo + llo * rmid + (lo ~/ _max24);
    // 16 * 24 + 24 * 24 + 16 * 24 + 50 / 24 --> <= 51 bits
    final hi = lhi * rlo + lmid * rmid + llo * rhi + (mid ~/ _max24);

    // recomposing 2x 32-bit
    _lo = (lo & 0x00FFFFFF) | ((mid & 0x000000FF) << 24);
    _hi = ((mid & 0x00FFFF00) >> 8) | ((hi & 0x0000FFFF) << 16);
  }

  @override
  void rotl(int n) {
    n %= 64;
    var lsh = 32 - n;
    if (lsh < 0) {
      final tmp = _hi;
      _hi = _lo;
      _lo = tmp;
      lsh += 32;
      n -= 32;
    }
    final m = (_mask32 << lsh) & _mask32;
    final hb = (_hi & m) >> lsh;
    final lb = (_lo & m) >> lsh;
    _hi = ((_hi << n) | lb) & _mask32;
    _lo = ((_lo << n) | hb) & _mask32;
  }

  @override
  void xor(IUint64 other) {
    other = other as Uint64_int;
    _lo ^= other._lo;
    _hi ^= other._hi;
  }

  @override
  void shl(int n) {
    final lsh = 32 - n;
    if (lsh <= 0) {
      _hi = (_lo << -lsh) & _mask32;
      _lo = 0;
    } else {
      final m = (_mask32 << lsh) & _mask32;
      _hi = ((_hi << n) | ((_lo & m) >> lsh)) & _mask32;
      _lo = (_lo << n) & _mask32;
    }
  }

  @override
  void xshr(int n) {
    final rsh = 32 - n;
    if (rsh <= 0) {
      _lo ^= (_hi >> -rsh) & _mask32;
    } else {
      final m = (_mask32 >> rsh) & _mask32;
      _lo ^= ((_lo >> n) | ((_hi & m) << rsh)) & _mask32;
      _hi ^= (_hi >> n) & _mask32;
    }
  }
}
