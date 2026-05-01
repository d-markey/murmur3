import 'dart:async';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

import '_helpers.dart';

class TestCase3a {
  TestCase3a(this.data, this.seed, this.result);

  final Object? data;
  final int seed;
  final int result;

  Future<void> check(MurmurHashV3 hash) async {
    final res = await hash.murmur3a(data, seed: seed);
    expect(hex(res, 32), equals(hex(result, 32)));
  }

  TestCase3a asStream() =>
      (data is Stream) ? this : TestCase3a(splitWorkload(data), seed, result);
}
