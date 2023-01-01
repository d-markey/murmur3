import 'dart:async';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

import '_helpers.dart';

class TestCase3f {
  TestCase3f(this.data, this.seed, this.result);

  final dynamic data;
  final int seed;
  final BigInt result;

  Future<void> check() async {
    final hash = await murmur3f(data, seed: seed);
    expect(hex(hash, 128), equals(hex(result, 128)));
  }

  TestCase3f asStream() {
    if (data is Stream) {
      return this;
    } else if (data is Iterable) {
      final parts = splitWorkload(data);
      return TestCase3f(Stream.fromIterable(parts), seed, result);
    } else if (data is String) {
      final parts =
          splitWorkload(data.runes).map((r) => String.fromCharCodes(r));
      return TestCase3f(Stream.fromIterable(parts), seed, result);
    } else {
      return TestCase3f(Stream.fromIterable([data]), seed, result);
    }
  }
}
