part of '_murmur_context.dart';

// ignore: camel_case_types
class MurmurContext3a extends MurmurContext<int> {
  MurmurContext3a(this._uint32, int seed) : super(4) {
    _hash = _uint32(seed);
  }

  @override
  int getHash() => _hash.value;

  late final IUint32 _hash;
  late final IUint32 _k = _uint32(0);

  final IUint32 Function(int num) _uint32;

  late final _c1 = _uint32(0xCC9E2D51);
  late final _c2 = _uint32(0x1B873593);
  late final _c3 = _uint32(0xE6546B64);
  late final _c4 = _uint32(0x85EBCA6B);
  late final _c5 = _uint32(0xC2B2AE35);

  late final _five = _uint32(5);

  @override
  int _loadBlock(List<int> bytes, int offset) =>
      _k.loadLEBytes(bytes, offset, fromByte: _pending);

  @override
  void _processBlock() {
    _k
      ..mul(_c1)
      ..rotl(15)
      ..mul(_c2);
    _hash
      ..xor(_k)
      ..rotl(13)
      ..mul(_five)
      ..add(_c3);
  }

  @override
  void _processTail() {
    _k
      ..mul(_c1)
      ..rotl(15)
      ..mul(_c2);
    _hash.xor(_k);
  }

  @override
  void _finalize() {
    _hash
      ..xor(_uint32(_length))
      ..xshr(16)
      ..mul(_c4)
      ..xshr(13)
      ..mul(_c5)
      ..xshr(16);
  }
}
