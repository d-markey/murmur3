import 'dart:math';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

final intendedError = 'intended error ${DateTime.now().toUtc()}';

final platform = bool.fromEnvironment('dart.library.io', defaultValue: false)
    ? 'VM'
    : (bool.fromEnvironment('dart.tool.dart2wasm', defaultValue: false)
        ? 'WASM'
        : (bool.fromEnvironment('dart.tool.dart2js', defaultValue: false)
            ? 'JS'
            : '???'));

final skipOnDart2Js = {
  'dart2js': Skip('Native 64-bit ints are not supported on this platform.')
};

String hex(Object num, int bits) => switch (num) {
      BigInt() => num.toRadixString(16).padLeft(bits ~/ 4, '0'),
      int() => num.toRadixString(16).padLeft(bits ~/ 4, '0'),
      _ => throw TypeException('Unsupported type: ${num.runtimeType}')
    };

Stream splitWorkload(Object? data) => switch (data) {
      Stream() => data,
      String() => _splitString(data),
      Iterable() => _splitIterable(data),
      _ => Stream.value(data)
    };

Stream _splitString(String data) async* {
  final items = data.runes.toList();
  final rnd = Random();
  while (items.isNotEmpty) {
    final p = items.take(rnd.nextInt(items.length + 1)).toList();
    if (p.isNotEmpty) {
      items.removeRange(0, p.length);
      yield String.fromCharCodes(p);
    }
  }
}

Stream<List> _splitIterable(Iterable data) async* {
  final items = data.toList();
  final rnd = Random();
  while (items.isNotEmpty) {
    final p = items.take(rnd.nextInt(items.length + 1)).toList();
    if (p.isNotEmpty) {
      items.removeRange(0, p.length);
      yield p;
    }
  }
}
