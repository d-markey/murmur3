import 'dart:convert';
import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

import 'helpers/_helpers.dart';
import 'helpers/test_case_3f.dart';

void main() {
  group('Uint64_BigInt - ', () {
    MurmurHashV3.useUInt64Impl(Uint64_BigInt.new);
    run();
  });

  group('Uint64_int - ', () {
    MurmurHashV3.useUInt64Impl(Uint64_int.new);
    run();
  });
}

void run() {
  // test cases found or built from
  // https://gist.github.com/vladimirgamalyan/defb2482feefbf5c3ea25b14c557753b
  // https://github.com/spaolacci/murmur3/blob/master/murmur_test.go
  // https://murmurhash.shorelabs.com/

  final emptyTestCases = <TestCase3f>[
    TestCase3f(Iterable<int>.empty(), 0, BigInt.zero),
    TestCase3f([], 0x2A, BigInt.parse('0xF02AA77DFA1B8523D1016610DA11CBB9')),

    // string
    TestCase3f('', 0, BigInt.zero),
    TestCase3f('', 0x2A, BigInt.parse('0xF02AA77DFA1B8523D1016610DA11CBB9')),
  ];

  final tailTestCases = <TestCase3f>[
    TestCase3f(
        Uint8List(1), 0, BigInt.parse('0x4610ABE56EFF5CB551622DAA78F83583')),
    TestCase3f(
        Uint8List(2), 0, BigInt.parse('0x3044B81A706C5DE818F96BCC37E8A35B')),

    // bool
    TestCase3f(false, 0, BigInt.parse('0x4610ABE56EFF5CB551622DAA78F83583')),
    TestCase3f(true, 0, BigInt.parse('0x7ACE5C908374FE16778867E4430E6785')),

    // byte
    TestCase3f(0, 0, BigInt.parse('0x4610ABE56EFF5CB551622DAA78F83583')),
    TestCase3f(1, 0, BigInt.parse('0x7ACE5C908374FE16778867E4430E6785')),

    // string
    TestCase3f('a', 0, BigInt.parse('0x85555565F6597889E6B53A48510E895A')),
    TestCase3f('b', 0, BigInt.parse('0x7A98A957B1D3D1EEFA2E131E544E94E9')),
    TestCase3f('ab', 0, BigInt.parse('0x938B11EA16ED1B2EE65EA7019B52D4AD')),
    TestCase3f('abcd', 0, BigInt.parse('0xB87BB7D64656CD4FF2003E886073E875')),
    TestCase3f(
        'abcdefg', 0, BigInt.parse('0xA6CD2F9FC09EE4991C3AA23AB155BBB6')),
    TestCase3f(
        'abcdefgh', 0, BigInt.parse('0xCC8A0AB037EF8C0248890D60EB6940A1')),
    TestCase3f(
        'abcdefghi', 0, BigInt.parse('0x0547C0CFF13C796479B53DF5B741E033')),
    TestCase3f('abcdefghijklmno', 0,
        BigInt.parse('0x8ABE2451890C2FFB6A548C2D9C962A61')),
    TestCase3f('hello', 0, BigInt.parse('0xCBD8A7B341BD9B025B1E906A48AE1D19')),
    TestCase3f(
        'hello, world', 0, BigInt.parse('0x342FAC623A5EBC8E4CDCBC079642414D')),
  ];

  final noTailTestCases = <TestCase3f>[
    TestCase3f('abcdefghijklmnop', 0,
        BigInt.parse('0xC4CA3CA3224CB7234333D695B331EB1A')),
    TestCase3f('f02aa77dfa1b8523d1016610da11cbb9', 0,
        BigInt.parse('0xFB9F2C5169F89A6C9FD92DCD2AF426D9')),
    TestCase3f('f02aa77dfa1b8523d1016610da11cbb9', 0x2A,
        BigInt.parse('0x7149C40EC7C51A23CF1CAA9A8C81CEA5')),
  ];

  final bodyAndTailTestCases = <TestCase3f>[
    TestCase3f('The quick brown fox jumps over the lazy dog', 0,
        BigInt.parse('0xE34BBC7BBC071B6C7A433CA9C49A9347')),
  ];

  final mixedInputTestCases = <TestCase3f>[
    TestCase3f(['The quick ', 'brown fox', ' jumps over the lazy dog'], 0,
        BigInt.parse('0xE34BBC7BBC071B6C7A433CA9C49A9347')),
    TestCase3f([
      'The qui',
      [Uint8List.fromList(utf8.encode('ck brown fox'))],
      ' jumps over the lazy dog'
    ], 0, BigInt.parse('0xE34BBC7BBC071B6C7A433CA9C49A9347')),
  ];

  test('murmur3f - no stream - empty', () async {
    for (var testCase in emptyTestCases) {
      await testCase.check();
    }
  });

  test('murmur3f - no stream - tail only', () async {
    for (var testCase in tailTestCases) {
      await testCase.check();
    }
  });

  test('murmur3f - no stream - no tail', () async {
    for (var testCase in noTailTestCases) {
      await testCase.check();
    }
  });

  test('murmur3f - no stream - body + tail', () async {
    for (var testCase in bodyAndTailTestCases) {
      await testCase.check();
    }
  });

  test('murmur3f - no stream - mixed input', () async {
    for (var testCase in mixedInputTestCases) {
      await testCase.check();
    }
  });

  test('murmur3f - stream - empty', () async {
    for (var testCase in emptyTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3f - stream tail only', () async {
    for (var testCase in tailTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3f - stream - no tail', () async {
    for (var testCase in noTailTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3f - stream - body + tail', () async {
    for (var testCase in bodyAndTailTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3f - stream - mixed input', () async {
    for (var testCase in mixedInputTestCases) {
      await testCase.asStream().check();
    }
  });

  test('murmur3f - invalid data', () async {
    try {
      murmur3f(256);
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      murmur3f([0, 1, 2, 256, 4]);
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      murmur3f(Object());
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('unsupported'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      await murmur3f(Stream.fromIterable([0, 1, 2, 256, 4]));
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('not a byte'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      await murmur3f(Stream.fromIterable([0, 1, 2, Object(), 4]));
      throw Exception('Managed to compute hash for non-byte data');
    } on TypeException catch (ex) {
      expect(ex.message.toLowerCase(), contains('unsupported'));
      expect(ex.toString(), contains('TypeException'));
      expect(ex.toString(), contains(ex.message));
    }

    try {
      Stream errorStream() async* {
        yield 0;
        yield 1;
        throw Exception(intendedError);
      }

      await murmur3f(errorStream());
      throw Exception('Managed to compute hash for a stream with errors');
    } catch (ex) {
      expect(ex.toString(), contains(intendedError));
    }
  });
}
