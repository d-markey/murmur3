import 'dart:async';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

import '_helpers.dart';

class TestCase3f {
  TestCase3f(this.data, int seed, this.result) : seed = BigInt.from(seed);

  final Object? data;
  final BigInt seed;
  final BigInt result;

  Future<void> check(MurmurHashV3 hash) async {
    final res = await hash.murmur3f(data, seed: seed);
    expect(hex(res, 128), equals(hex(result, 128)));
  }

  TestCase3f asStream() => (data is Stream)
      ? this
      : TestCase3f(splitWorkload(data), seed.toInt(), result);
}
