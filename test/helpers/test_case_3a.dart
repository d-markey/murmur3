import 'dart:async';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

import '_helpers.dart';

class TestCase3a {
  TestCase3a(this.data, this.seed, this.result);

  final dynamic data;
  final int seed;
  final int result;

  Future<void> check() async {
    final hash = await murmur3a(data, seed: seed);
    expect(hex(hash, 32), equals(hex(result, 32)));
  }

  TestCase3a asStream() {
    if (data is Stream) {
      return this;
    } else if (data is Iterable) {
      final parts = splitWorkload(data);
      return TestCase3a(Stream.fromIterable(parts), seed, result);
    } else if (data is String) {
      final parts =
          splitWorkload(data.runes).map((r) => String.fromCharCodes(r));
      return TestCase3a(Stream.fromIterable(parts), seed, result);
    } else {
      return TestCase3a(Stream.fromIterable([data]), seed, result);
    }
  }
}
