part of '_murmur_context.dart';

// ignore: camel_case_types
class MurmurContext3f extends MurmurContext<BigInt> {
  MurmurContext3f(this._uint64, BigInt seed) : super(16) {
    final lo = seed & BigInt.parse('0x0000000000000000FFFFFFFFFFFFFFFF');
    var hi = seed & BigInt.parse('0xFFFFFFFFFFFFFFFF0000000000000000') >> 64;
    if (hi == BigInt.zero) {
      hi = lo;
    }
    _hash1 = _uint64(lo);
    _hash2 = _uint64(hi);
  }

  @override
  BigInt getHash() => (_hash1.value << 64) | _hash2.value;

  late final IUint64 _hash1;
  late final IUint64 _hash2;
  late final IUint64 _k1 = _uint64(0);
  late final IUint64 _k2 = _uint64(0);

  final IUint64 Function(dynamic num) _uint64;

  late final _c1 = _uint64('0x87C37B91114253D5');
  late final _c2 = _uint64('0x4CF5AD432745937F');
  late final _c3 = _uint64(0x52DCE729);
  late final _c4 = _uint64(0x38495AB5);
  late final _c5 = _uint64('0xFF51AFD7ED558CCD');
  late final _c6 = _uint64('0xC4CEB9FE1A85EC53');

  late final _five = _uint64(5);

  @override
  int _loadBlock(List<int> bytes, int offset) {
    var count = 0;
    if (_pending < 8) {
      count += _k1.loadLEBytes(bytes, offset, fromByte: _pending);
      count += _k2.loadLEBytes(bytes, offset + 8 - _pending);
    } else {
      count += _k2.loadLEBytes(bytes, offset, fromByte: _pending - 8);
    }
    return count;
  }

  @override
  void _processBlock() {
    _k1
      ..mul(_c1)
      ..rotl(31)
      ..mul(_c2);
    _hash1
      ..xor(_k1)
      ..rotl(27)
      ..add(_hash2)
      ..mul(_five)
      ..add(_c3);

    _k2
      ..mul(_c2)
      ..rotl(33)
      ..mul(_c1);
    _hash2
      ..xor(_k2)
      ..rotl(31)
      ..add(_hash1)
      ..mul(_five)
      ..add(_c4);
  }

  @override
  void _processTail() {
    _k2
      ..mul(_c2)
      ..rotl(33)
      ..mul(_c1);
    _hash2.xor(_k2);

    _k1
      ..mul(_c1)
      ..rotl(31)
      ..mul(_c2);
    _hash1.xor(_k1);
  }

  @override
  void _finalize() {
    final l = _uint64(_length);
    _hash1.xor(l);
    _hash2.xor(l);
    _hash1.add(_hash2);
    _hash2.add(_hash1);
    _mix(_hash1);
    _mix(_hash2);
    _hash1.add(_hash2);
    _hash2.add(_hash1);
  }

  void _mix(IUint64 hash) => hash
    ..xshr(33)
    ..mul(_c5)
    ..xshr(33)
    ..mul(_c6)
    ..xshr(33);
}
