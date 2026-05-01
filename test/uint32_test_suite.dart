import 'dart:math';
import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';
import 'package:murmur3/src/_helpers.dart';
import 'package:test/test.dart';

import 'helpers/_helpers.dart';

void main() {
  group('[$platform] uint32 - $Uint32_int_64bit_mul - ', () {
    testUint32(Uint32_int_64bit_mul.new);
  }, onPlatform: skipOnDart2Js);

  group('[$platform] uint32 - $Uint32_int_48bit_mul - ', () {
    testUint32(Uint32_int_48bit_mul.new);
  });
}

int _fromBin(String bits) => int.parse(bits, radix: 2);

ByteData _bd(List<int> list) => Uint8List.fromList(list).buffer.asByteData();

void testUint32(FUint32 uint32) {
  test('Little-endian bytes loading', () {
    final bytes = [0xAB, 0x01, 0xFE, 0xCA, 0xBB, 0xBB, 0xBB];
    final a = uint32(0);

    a.loadLEBytes(_bd(bytes.sublist(3, 4)), 0);
    a.eq(0x000000CA);

    a.loadLEBytes(_bd(bytes.sublist(2, 4)), 0);
    a.eq(0x0000CAFE);

    a.loadLEBytes(_bd(bytes.sublist(1, 4)), 0);
    a.eq(0x00CAFE01);

    a.loadLEBytes(_bd(bytes), 0);
    a.eq(0xCAFE01AB);
  });

  test('Little-endian bytes loading - continuation', () {
    final bytes = [0xAB, 0x01, 0xFE, 0xCA, 0xBB, 0xBB];
    final a = uint32(0);

    var count = a.loadLEBytes(_bd(bytes.sublist(0, 2)), 0);
    a.eq(0x000001AB);
    expect(count, 2);

    count += a.loadLEBytes(_bd(bytes.sublist(2, 3)), 0, fromByte: count);
    a.eq(0xFE01AB);
    expect(count, 3);

    count += a.loadLEBytes(_bd(bytes.sublist(3)), 0, fromByte: count);
    a.eq(0xCAFE01AB);
    expect(count, 4);
  });

  test('In-place addition', () {
    for (var ai in _Ints.random) {
      for (var bi in _Ints.random) {
        final a = uint32(ai);
        final b = uint32(bi);
        a.add(b);
        a.eq(ai + bi);
      }
    }
  });

  test('In-place multiplication', () {
    for (var ai in _Ints.random) {
      for (var bi in _Ints.random) {
        final a = uint32(ai);
        final b = uint32(bi);
        a.mul(b);
        a.eq(BigInt.from(ai) * BigInt.from(bi));
      }
    }
  });

  test('In-place XOR operation', () {
    for (var ai in _Ints.random) {
      for (var bi in _Ints.random) {
        final a = uint32(ai);
        final b = uint32(bi);
        a.xor(b);
        a.eq(ai ^ bi);
      }
    }
  });

  test('In-place XOR + right shift operation', () {
    for (var ai in _Ints.random) {
      for (var n = 0; n <= 64; n++) {
        final a = uint32(ai);
        a.xshr(n);
        a.eq(ai ^ (ai >> n));
      }
    }
  });

  test('In-place left rotation', () {
    for (var ai in _Ints.random) {
      for (var n = 0; n <= 32; n++) {
        final a = uint32(ai);
        a.rotl(n);
        final s = ai.toRadixString(2).padLeft(32, '0');
        final res = _fromBin(s.substring(n % 32) + s.substring(0, n % 32));
        a.eq(res);
      }
    }
  });

  test('In-place left shift', () {
    for (var ai in _Ints.random) {
      for (var n = 0; n <= 32; n++) {
        final a = uint32(ai);
        a.shl(n);
        a.eq(ai << n);
      }
    }
  });
}

extension _ExpectExt on IUint32 {
  static final _mask = BigInt.from(0xFFFFFFFF);

  void eq(Object res) => expect(
      hex(BigInt.from(value), 32), equals(hex(toBigInt(res) & _mask, 32)));
}

class _Ints {
  static final _full16bits = 0x0000FFFF;
  static final _full32bits = 0xFFFFFFFF;

  static final _rnd = Random();

  static Iterable<int> get random sync* {
    yield 0;
    for (var i = 0; i < 32; i++) {
      var b = 0;
      for (var j = 0; j < i; j++) {
        b = (b << 1) + _rnd.nextInt(2);
      }
      yield b;
    }
    yield _full16bits;
    yield _full32bits;
  }
}
