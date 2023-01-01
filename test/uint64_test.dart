import 'dart:math';

import 'package:murmur3/murmur3.dart';
import 'package:murmur3/src/uint.dart';
import 'package:test/test.dart';

import 'helpers/_helpers.dart';

void main() {
  group('uint64 - $Uint64_BigInt - ', () {
    testUint64(Uint64_BigInt.new);
  });

  group('uint64 - $Uint64_int - ', () {
    testUint64(Uint64_int.new);
  });
}

BigInt $bin(String bits) => BigInt.parse(bits, radix: 2);
BigInt $hex(String hex) => BigInt.parse(hex, radix: 16);

void testUint64(IUint64 Function(dynamic n) uint64) {
  test('Little-endian bytes loading', () {
    final bytes = [0xAB, 0x01, 0xFE, 0xCA, 0x01, 0x02, 0xFF, 0xFE, 0xBB, 0xBB];
    final a = uint64(0);

    var count = a.loadLEBytes(bytes.sublist(7, 8), 0);
    a.eq(BigInt.from(bytes[7]));
    expect(count, equals(1));

    count = a.loadLEBytes(bytes.sublist(6, 8), 0);
    a.eq($hex('000000000000FEFF'));
    expect(count, equals(2));

    count = a.loadLEBytes(bytes.sublist(5, 8), 0);
    a.eq($hex('0000000000FEFF02'));
    expect(count, equals(3));

    count = a.loadLEBytes(bytes.sublist(4, 8), 0);
    a.eq($hex('00000000FEFF0201'));
    expect(count, equals(4));

    count = a.loadLEBytes(bytes.sublist(3, 8), 0);
    a.eq($hex('000000FEFF0201CA'));
    expect(count, equals(5));

    count = a.loadLEBytes(bytes.sublist(2, 8), 0);
    a.eq($hex('0000FEFF0201CAFE'));
    expect(count, equals(6));

    count = a.loadLEBytes(bytes.sublist(1, 8), 0);
    a.eq($hex('00FEFF0201CAFE01'));
    expect(count, equals(7));

    count = a.loadLEBytes(bytes, 0);
    a.eq($hex('FEFF0201CAFE01AB'));
    expect(count, equals(8));
  });

  test('Little-endian bytes loading - continuation', () {
    final bytes = [0xAB, 0x01, 0xFE, 0xCA, 0x01, 0x02, 0xFF, 0xFE, 0xBB, 0xBB];
    final a = uint64(0);

    var count = a.loadLEBytes(bytes.sublist(0, 3), 0);
    a.eq($hex('0000000000FE01AB'));
    expect(count, equals(3));

    count += a.loadLEBytes(bytes.sublist(3, 5), 0, fromByte: count);
    a.eq($hex('00000001CAFE01AB'));
    expect(count, equals(5));

    count += a.loadLEBytes(bytes.sublist(5), 0, fromByte: count);
    a.eq($hex('FEFF0201CAFE01AB'));
    expect(count, equals(8));
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
        final res = $bin(s.substring(n % 64) + s.substring(0, n % 64));
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
}

extension _ExpectExt on IUint64 {
  static final _mask = $hex('FFFFFFFFFFFFFFFF');

  void eq(BigInt res) => expect(hex(value, 64), equals(hex(res & _mask, 64)));
}

class _BigInts {
  static final _full32bits = $hex('00000000FFFFFFFF');
  static final _full64bits = $hex('FFFFFFFFFFFFFFFF');

  static final _rnd = Random();

  static Iterable<BigInt> get random sync* {
    yield BigInt.zero;
    for (var i = 0; i < 64; i++) {
      var b = BigInt.one;
      for (var j = 0; j < i; j++) {
        b = (b << 1) + BigInt.from(_rnd.nextInt(2));
      }
      yield b;
    }
    yield _full32bits;
    yield _full64bits;
  }
}
