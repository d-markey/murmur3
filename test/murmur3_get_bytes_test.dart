import 'dart:convert';
import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';
import 'package:test/test.dart';

void main() {
  group('Byte conversions - ', () {
    test('byte', () {
      for (var i = 0; i <= 255; i++) {
        var array = MurmurHashV3.getBytes(i);
        expect(array.length, equals(1));
        expect(array[0], equals(i));
      }
    });

    test('bool', () {
      var array = MurmurHashV3.getBytes(true);
      expect(array.length, equals(1));
      expect(array[0], equals(1));

      array = MurmurHashV3.getBytes(false);
      expect(array.length, equals(1));
      expect(array[0], equals(0));
    });

    test('String', () {
      var text = 'Hello, World!';
      var array = MurmurHashV3.getBytes(text);
      expect(array, orderedEquals(utf8.encode(text)));

      text = 'Texte en français, avec des caractères accentués';
      array = MurmurHashV3.getBytes(text);
      expect(array, orderedEquals(utf8.encode(text)));
    });

    test('Uint8List', () {
      var bytes = Uint8List.fromList([1, 2, 3, 5, 8, 13, 21, 34, 55, 89]);
      var array = MurmurHashV3.getBytes(bytes);
      expect(array, orderedEquals([1, 2, 3, 5, 8, 13, 21, 34, 55, 89]));

      bytes = Uint8List(0);
      array = MurmurHashV3.getBytes(bytes);
      expect(array, orderedEquals([]));
    });

    test('Iterable<num>', () {
      var array = MurmurHashV3.getBytes(Iterable<int>.empty());
      expect(array, orderedEquals([]));

      var ints = <int>[1, 2, 3, 4, 5];
      array = MurmurHashV3.getBytes(ints.map((i) => 2 * i));
      expect(array, orderedEquals([2, 4, 6, 8, 10]));

      array = MurmurHashV3.getBytes(Iterable<double>.empty());
      expect(array, orderedEquals([]));

      var doubles = <double>[1.0, 3.0, 5.0];
      array = MurmurHashV3.getBytes(doubles.map((d) => 3 * d));
      expect(array, orderedEquals([3, 9, 15]));
    });

    test('Mixed iterable', () {
      var input = [
        1,
        [true],
        false,
        2,
        [3.0, 4.0, 5, 'abc'],
        'def',
        0xFF
      ];
      var array = MurmurHashV3.getBytes(input);
      expect(
          array,
          orderedEquals([1, 1, 0, 2, 3, 4, 5]
              .followedBy(utf8.encode('abcdef'))
              .followedBy([255])));
    });
  });
}
