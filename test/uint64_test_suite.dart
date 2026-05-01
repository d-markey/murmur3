import 'dart:math';
import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

import 'helpers/_helpers.dart';

void main() {
  group('[$platform] uint64 - $Uint64_BigInt - ', () {
    testUint64(Uint64_BigInt.new);
  });

  group('[$platform] uint64 - $Uint64_int - ', () {
    testUint64(Uint64_int.new);
  });

  group('[$platform] uint64 - $Uint64_native - ', () {
    testUint64(Uint64_native.new);
  }, onPlatform: skipOnDart2Js);
}

BigInt _fromBin(String bits) => BigInt.parse(bits, radix: 2);
BigInt _fromHex(String hex) => BigInt.parse(hex, radix: 16);

ByteData _bd(List<int> list) => Uint8List.fromList(list).buffer.asByteData();

void testUint64(FUint64 uint64) {
  test('Little-endian bytes loading', () {
    final bytes = [0xAB, 0x01, 0xFE, 0xCA, 0x01, 0x02, 0xFF, 0xFE, 0xBB, 0xBB];
    final a = uint64(0);

    var count = a.loadLEBytes(_bd(bytes.sublist(7, 8)), 0);
    a.eq(_fromHex('00000000000000FE'));
    expect(count, 1);

    count = a.loadLEBytes(_bd(bytes.sublist(6, 8)), 0);
    a.eq(_fromHex('000000000000FEFF'));
    expect(count, 2);

    count = a.loadLEBytes(_bd(bytes.sublist(5, 8)), 0);
    a.eq(_fromHex('0000000000FEFF02'));
    expect(count, 3);

    count = a.loadLEBytes(_bd(bytes.sublist(4, 8)), 0);
    a.eq(_fromHex('00000000FEFF0201'));
    expect(count, 4);

    count = a.loadLEBytes(_bd(bytes.sublist(3, 8)), 0);
    a.eq(_fromHex('000000FEFF0201CA'));
    expect(count, 5);

    count = a.loadLEBytes(_bd(bytes.sublist(2, 8)), 0);
    a.eq(_fromHex('0000FEFF0201CAFE'));
    expect(count, 6);

    count = a.loadLEBytes(_bd(bytes.sublist(1, 8)), 0);
    a.eq(_fromHex('00FEFF0201CAFE01'));
    expect(count, 7);

    count = a.loadLEBytes(_bd(bytes), 0);
    a.eq(_fromHex('FEFF0201CAFE01AB'));
    expect(count, 8);
  });

  test('Little-endian bytes loading - continuation', () {
    final bytes = [0xAB, 0x01, 0xFE, 0xCA, 0x01, 0x02, 0xFF, 0xFE, 0xBB, 0xBB];
    final a = uint64(0);

    var count = a.loadLEBytes(_bd(bytes.sublist(0, 3)), 0);
    a.eq(_fromHex('0000000000FE01AB'));
    expect(count, 3);

    count += a.loadLEBytes(_bd(bytes.sublist(3, 5)), 0, fromByte: count);
    a.eq(_fromHex('00000001CAFE01AB'));
    expect(count, 5);

    count += a.loadLEBytes(_bd(bytes.sublist(5)), 0, fromByte: count);
    a.eq(_fromHex('FEFF0201CAFE01AB'));
    expect(count, 8);
  });

  test('In-place addition', () {
    for (var abi in _BigInts.random) {
      for (var bbi in _BigInts.random) {
        final a = uint64(abi);
        final b = uint64(bbi);
        a.add(b);
        a.eq(abi + bbi);
      }
    }
  });

  test('In-place multiplication', () {
    for (var abi in _BigInts.random) {
      for (var bbi in _BigInts.random) {
        final a = uint64(abi);
        final b = uint64(bbi);
        a.mul(b);
        a.eq(abi * bbi);
      }
    }
  });

  test('In-place XOR operation', () {
    for (var abi in _BigInts.random) {
      for (var bbi in _BigInts.random) {
        final a = uint64(abi);
        final b = uint64(bbi);
        a.xor(b);
        a.eq(abi ^ bbi);
      }
    }
  });

  test('In-place XOR + right shift operation', () {
    for (var abi in _BigInts.random) {
      for (var n = 0; n <= 64; n++) {
        final a = uint64(abi);
        a.xshr(n);
        a.eq(abi ^ (abi >> n));
      }
    }
  });

  test('In-place left rotation', () {
    for (var abi in _BigInts.random) {
      for (var n = 0; n <= 64; n++) {
        final a = uint64(abi);
        a.rotl(n);
        final s = abi.toRadixString(2).padLeft(64, '0');
        final res = _fromBin(s.substring(n % 64) + s.substring(0, n % 64));
        a.eq(res);
      }
    }
  });

  test('In-place left shift', () {
    for (var abi in _BigInts.random) {
      for (var n = 0; n <= 64; n++) {
        final a = uint64(abi);
        a.shl(n);
        a.eq(abi << n);
      }
    }
  });

  test('Unsigned behavior for negative/large inputs', () {
    // Initializing with -1 should result in 0xFFFFFFFFFFFFFFFF
    final a = uint64(-1);
    final b = uint64(BigInt.from(-1));
    final c = uint64('0xFFFFFFFFFFFFFFFF');

    final max64 = _fromHex('FFFFFFFFFFFFFFFF');
    a.eq(max64);
    b.eq(max64);
    c.eq(max64);

    // Unsigned right shift of all-ones (value ^= value >>> n)
    // 0xFFFFFFFFFFFFFFFF ^ 0x7FFFFFFFFFFFFFFF = 0x8000000000000000
    a.xshr(1);
    a.eq(_fromHex('8000000000000000'));
  });
}

extension _ExpectExt on IUint64 {
  static final _mask = _fromHex('FFFFFFFFFFFFFFFF');

  void eq(BigInt res) => expect(hex(value, 64), equals(hex(res & _mask, 64)));
}

class _BigInts {
  static final _full32bits = _fromHex('00000000FFFFFFFF');
  static final _full64bits = _fromHex('FFFFFFFFFFFFFFFF');

  static final _rnd = Random();

  static Iterable<BigInt> get random sync* {
    yield BigInt.zero;
    for (var i = 0; i < 64; i++) {
      var b = BigInt.zero;
      for (var j = 0; j < i; j++) {
        b = (b << 1) + BigInt.from(_rnd.nextInt(2));
      }
      yield b;
    }
    yield _full32bits;
    yield _full64bits;
  }
}
