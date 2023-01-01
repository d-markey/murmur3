[![Pub Package](https://img.shields.io/pub/v/murmur3)](https://pub.dev/packages/murmur3)
[![Dart Platforms](https://badgen.net/pub/dart-platform/murmur3)](https://pub.dev/packages/murmur3)
[![Flutter Platforms](https://badgen.net/pub/flutter-platform/murmur3)](https://pub.dev/packages/murmur3)

[![License](https://img.shields.io/github/license/d-markey/murmur3)](https://github.com/d-markey/murmur3/blob/master/LICENSE)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Dart Style](https://img.shields.io/badge/style-lints-40c4ff)](https://pub.dev/packages/lints)
[![Pub Points](https://img.shields.io/pub/points/murmur3)](https://pub.dev/packages/murmur3/score)
[![Likes](https://img.shields.io/pub/likes/murmur3)](https://pub.dev/packages/murmur3/score)
[![Popularity](https://img.shields.io/pub/popularity/murmur3)](https://pub.dev/packages/murmur3/score)

[![Last Commit](https://img.shields.io/github/last-commit/d-markey/murmur3?logo=git&logoColor=white)](https://github.com/d-markey/murmur3/commits)
[![Dart Workflow](https://github.com/d-markey/murmur3/actions/workflows/dart.yml/badge.svg?logo=dart)](https://github.com/d-markey/murmur3/actions/workflows/dart.yml)
[![Code Lines](https://img.shields.io/badge/dynamic/json?color=blue&label=code%20lines&query=%24.linesValid&url=https%3A%2F%2Fraw.githubusercontent.com%2Fd-markey%2Fmurmur3%2Fmain%2Fcoverage.json)](https://github.com/d-markey/murmur3/tree/main/coverage/html)
[![Code Coverage](https://img.shields.io/badge/dynamic/json?color=blue&label=code%20coverage&query=%24.lineRate&suffix=%25&url=https%3A%2F%2Fraw.githubusercontent.com%2Fd-markey%2Fmurmur3%2Fmain%2Fcoverage.json)](https://github.com/d-markey/murmur3/tree/main/coverage/html)

# murmur3

MurmurHash v3 for Dart &amp; Flutter.

Supports array and stream data sources, on native and browser platforms.

## Example

```dart
void main() async {
  final hash32 = murmur3a('div200').toHex(32);
  print('murmur3a(\'div2000\') = 0x$hash32');

  final hash128x64 = murmur3f('div200').toHex(128);
  print('murmur3f(\'div2000\') = 0x$hash128x64');

  final pkBytes = Stream.fromIterable([0x08, 'div200', 0x00]);
  final pkHash = encodeHash((await murmur3a(pkBytes)).toDouble());
  print('div200 pk hash = ${pkHash.map((b) => b.toHex(8)).join()}');
}
```
