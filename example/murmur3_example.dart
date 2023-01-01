import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';

void main() async {
  print('');
  final hash32 = murmur3a('div200').toHex(32);
  print('murmur3a(\'div2000\') = 0x$hash32');

  final hash128x64 = murmur3f('div200').toHex(128);
  print('murmur3f(\'div2000\') = 0x$hash128x64');

  final pkBytes = Stream.fromIterable([0x08, 'div200', 0x00]);
  final pkHash = encodeHash((await murmur3a(pkBytes)).toDouble());
  print('div200 pk hash = ${pkHash.map((b) => b.toHex(8)).join()}');
  print('');
}

final mask64bit = BigInt.parse('0xFFFFFFFFFFFFFFFF');
final max = BigInt.parse('9223372036854775808');

List<int> encodeHash(double value) {
  var buffer = <int>[];
  buffer.add(0x05);
  var num = encodeDoubleAsUInt64(value);
  buffer.add((num >> 0x38).toInt() & 0xFF);
  num = (num << 8) & mask64bit;
  var num2 = 0;
  var flag = true;
  do {
    if (!flag) {
      buffer.add(num2);
    } else {
      flag = false;
    }
    num2 = ((num >> 0x38).toInt() & 0xFF) | 0x01;
    num = (num << 7) & mask64bit;
  } while (num != BigInt.zero);
  buffer.add(num2 & 0xFE);
  return buffer;
}

BigInt encodeDoubleAsUInt64(double value) {
  final dl = Float64List.fromList([value]);
  var bytes = dl.buffer.asUint8List();
  if (Endian.host == Endian.big) {
    bytes = Uint8List.fromList(bytes.reversed.toList());
  }

  var idx = 8;
  var hi = 0;
  while (idx > 4) {
    idx--;
    hi = (hi << 8) | bytes[idx];
  }
  var lo = 0;
  while (idx > 0) {
    idx--;
    lo = (lo << 8) | bytes[idx];
  }

  final num = (BigInt.from(hi) << 32) | BigInt.from(lo);
  return (num >= max) ? (~num + BigInt.one) : (num ^ max);
}

extension IntHexExt on dynamic {
  toHex(int bits) => toRadixString(16).padLeft(bits ~/ 4, '0').toUpperCase();
}
