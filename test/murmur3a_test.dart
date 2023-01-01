import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

import 'helpers/_helpers.dart';
import 'helpers/test_case_3a.dart';

void main() {
  group('Uint32_int_48bit_mul - ', () {
    MurmurHashV3.useUInt32Impl(Uint32_int_48bit_mul.new);
    run();
  });

  group('Uint32_int_64bit_mul - ', () {
    MurmurHashV3.useUInt32Impl(Uint32_int_64bit_mul.new);
    run();
  });

  group('Uint32_int_xplat - ', () {
    MurmurHashV3.useUInt32Impl(Uint32_int_xplat.new);
    run();
  });
}

void run() {
  // test cases found or built from
  // https://gist.github.com/vladimirgamalyan/defb2482feefbf5c3ea25b14c557753b
  // https://github.com/spaolacci/murmur3/blob/master/murmur_test.go
  // https://murmurhash.shorelabs.com/

  final emptyTestCases = [
    // with zero data and zero seed, everything becomes zero
    TestCase3a(Iterable<int>.empty(), 0, 0),
    // ignores nearly all the math
    TestCase3a(Iterable<int>.empty(), 1, 0x514E28B7),
    // make sure your seed uses unsigned 32-bit math
    TestCase3a([], 0xFFFFFFFF, 0x81F16F39),

    // strings
    TestCase3a('', 0, 0), // empty string with zero seed should give zero
    TestCase3a('', 1, 0x514E28B7),
    TestCase3a('', 0xFFFFFFFF, 0x81F16F39),
  ];

  final tailTestCases = [
    // Only three bytes. Should end up as 0x654321
    TestCase3a([0x21, 0x43, 0x65, 0x87].take(3), 0, 0x7E4A8634),
    // Only two bytes. Should end up as 0x4321
    TestCase3a([0x21, 0x43, 0x65, 0x87].take(2), 0, 0xA0F7B07A),
    // Only one byte. Should end up as 0x21
    TestCase3a([0x21, 0x43, 0x65, 0x87].take(1), 0, 0x72661CF4),
    // Make sure compiler doesn't see zero and convert to null
    TestCase3a(Uint8List(3), 0, 0x85F0B427), // [0, 0, 0]
    TestCase3a(Uint8List(2), 0, 0x30F4C306), // [0, 0]
    TestCase3a(Uint8List(1), 0, 0x514E28B7), // [0]

    // bool
    TestCase3a(false, 0, 0x514E28B7),
    TestCase3a(true, 0, 0xE45AD1AB),

    // byte
    TestCase3a(0, 0, 0x514E28B7),
    TestCase3a(1, 0, 0xE45AD1AB),
    TestCase3a(0x21, 0, 0x72661CF4),

    // strings
    TestCase3a('aaa', 0x9747B28C, 0x283E0130),
    TestCase3a('aa', 0x9747B28C, 0x5D211726),
    TestCase3a('a', 0x9747B28C, 0x7FA09EA6),

    TestCase3a('abc', 0x9747B28C, 0xC84A62DD),
    TestCase3a('ab', 0x9747B28C, 0x74875592),
    TestCase3a('a', 0x9747B28C, 0x7FA09EA6),

    TestCase3a('abc', 0, 0xB3DD93FA),
  ];

  final noTailTestCases = [
    // make sure 4-byte chunks use unsigned math
    TestCase3a(Iterable.generate(4, (_) => 0xFF), 0, 0x76293B50),
    // Endian order. UInt32 should end up as 0x87654321
    TestCase3a([0x21, 0x43, 0x65, 0x87], 0, 0xF55B516B),
    // Special seed value eliminates initial key with xor
    TestCase3a([0x21, 0x43, 0x65, 0x87], 0x5082EDEE, 0x2362F9DE),
    TestCase3a(Uint8List(4), 0, 0x2362F9DE), // [0, 0, 0, 0]

    // Strings
    TestCase3a('aaaa', 0x9747B28C, 0x5A97808A),
    TestCase3a('abcd', 0x9747B28C, 0xF0478627),
    TestCase3a('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq', 0,
        0xEE925B90),
  ];

  final bodyAndTailTestCases = [
    TestCase3a('Hello, world!', 0x9747B28C, 0x24884CBA),
    TestCase3a(
        'The quick brown fox jumps over the lazy dog', 0x9747B28C, 0x2FA826CD),
  ];

  final mixedInputTestCases = [
    TestCase3a(['Hel', 'lo, world!'], 0x9747B28C, 0x24884CBA),
    TestCase3a(['The quick', ' brown fox jumps over t', 'he lazy dog'],
        0x9747B28C, 0x2FA826CD),
    TestCase3a([
      [0x21, 0x43],
      [0x65, 0x87]
    ], 0, 0xF55B516B),
    // Special seed value eliminates initial key with xor
    TestCase3a([
      0x21,
      [0x43, 0x65],
      0x87
    ], 0x5082EDEE, 0x2362F9DE),
    TestCase3a(<num>[0x21, 0x43, 0x65, 0x87], 0x5082EDEE, 0x2362F9DE),
  ];

  test('murmur3a - no stream - empty', () async {
    for (var testCase in emptyTestCases) {
      await testCase.check();
    }
  });

  test('murmur3a - no stream - tail only', () async {
    for (var testCase in tailTestCases) {
      await testCase.check();
    }
  });

  test('murmur3a - no stream - no tail', () async {
    for (var testCase in noTailTestCases) {
      await testCase.check();
    }
  });

  test('murmur3a - no stream - body + tail', () async {
    for (var testCase in bodyAndTailTestCases) {
      await testCase.check();
    }
  });

  test('murmur3a - no stream - mixed input', () async {
    for (var testCase in mixedInputTestCases) {
      await testCase.check();
    }
  });

  test('murmur3a - stream - empty', () async {
    for (var testCase in emptyTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3a - stream - tail only', () async {
    for (var testCase in tailTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3a - stream - no tail', () async {
    for (var testCase in noTailTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3a - stream - body + tail', () async {
    for (var testCase in bodyAndTailTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3a - stream - mixed input', () async {
    for (var testCase in mixedInputTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3a - invalid data', () async {
    try {
      murmur3a(256);
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      murmur3a([
        0,
        [1, 2],
        256,
        4
      ]);
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      murmur3a([
        0,
        [1, 2],
        Object(),
        256
      ]);
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('unsupported'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      murmur3a([
        0,
        [1, 2],
        256,
        Object()
      ]);
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      murmur3a(Object());
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('unsupported'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      await murmur3a(Stream.fromIterable([0, 1, 2, 256, 4]));
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      await murmur3a(Stream.fromIterable(<num>[0, 1, 2.4, 256, 4]));
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      await murmur3a(Stream.fromIterable([
        0,
        1,
        2,
        [Object(), 4]
      ]));
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('unsupported'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      await murmur3a(Stream.fromIterable([
        0,
        1,
        2,
        [256, Object(), 4]
      ]));
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      Stream errorStream() async* {
        yield 0;
        yield 1;
        throw Exception(intendedError);
      }

      await murmur3a(errorStream());
      throw Exception('Managed to compute hash for a stream with errors');
    } catch (ex) {
      expect(ex.toString(), contains(intendedError));
    }
  });
}
