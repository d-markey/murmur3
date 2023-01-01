import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';

import 'helpers/stats.dart';

typedef HashFunction = FutureOr Function(Stream stream, int seed);

void main() async {
  print('Platform uint32 is $Uint32_int_xplat');
  final os = (Uint32_int_xplat == Uint32_int_48bit_mul) ? 'browser' : 'vm';
  final mb = (Uint32_int_xplat == Uint32_int_48bit_mul) ? 2 : 20;

  // warm up
  run(PerfStats(), 100);

  // run
  final perfs = PerfStats();
  final sw = Stopwatch()..start();
  for (var i = 0; i < 10; i++) {
    await run(perfs, mb * 1024 * 1024);
  }

  // display stats
  print('${sw.elapsed} - Stream - $os');
  print(perfs);
}

Future run(PerfStats perfStats, int length) async {
  MurmurHashV3.useUInt32Impl(Uint32_int_64bit_mul.new);
  await perfStats.measure('murmur3a', '$Uint32_int_64bit_mul', length);

  MurmurHashV3.useUInt32Impl(Uint32_int_48bit_mul.new);
  await perfStats.measure('murmur3a', '$Uint32_int_48bit_mul', length);

  MurmurHashV3.useUInt64Impl(Uint64_BigInt.new);
  await perfStats.measure('murmur3f', '$Uint64_BigInt', length);

  MurmurHashV3.useUInt64Impl(Uint64_int.new);
  await perfStats.measure('murmur3f', '$Uint64_int', length);
}

class PerfStats {
  final _algorithms = <String, HashFunction>{
    'murmur3a': (stream, seed) => murmur3a(stream, seed: seed),
    'murmur3f': (stream, seed) => murmur3f(stream, seed: seed),
  };

  final _stats = <String, Stats>{};

  void _add(String label, int length, Duration duration) {
    final stat = _stats.putIfAbsent(label, () => Stats(label));
    stat.add(length, duration);
  }

  Iterable<Stats> get stats => _stats.values;

  Stream<List<int>> byteStream(int totalLength) {
    final rnd = Random();
    final max = 8 * 1024;
    final data = <Uint8List>[];
    while (totalLength > 0) {
      final length = rnd.nextInt(totalLength > max ? max : totalLength + 1);
      totalLength -= length;
      final bytes =
          Uint8List.fromList(List.generate(length, (_) => rnd.nextInt(256)));
      data.add(bytes);
    }
    return Stream.fromIterable(data);
  }

  Future<void> measure(
      String algorithm, String variant, int totalLength) async {
    final hash = _algorithms[algorithm]!;
    final stream = byteStream(totalLength);
    final sw = Stopwatch()..start();
    await hash(stream, 0);
    sw.stop();
    _add('$algorithm - $variant', totalLength, sw.elapsed);
  }

  @override
  String toString() =>
      _stats.entries.map((e) => '${e.key}: ${e.value}').join('\n');
}
