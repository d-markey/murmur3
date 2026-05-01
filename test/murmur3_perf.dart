// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:murmur3/murmur3.dart';

import 'helpers/stats.dart';

void main() async {
  // warm up
  stdout.writeln('Warming up...');
  ArrayPerfRunner(400).run();
  await StreamPerfRunner(512 * 1024).run();
  stdout.writeln('Running tests...');

  ///////// SYNC PERFS - data converted to list of bytes /////////

  // run
  stdout.write('Sync');
  final arrayPerfs = ArrayPerfRunner(2000);
  final sw = Stopwatch()..start();
  for (var i = 0; i < 10; i++) {
    stdout.write('.');
    arrayPerfs.run();
  }
  stdout.writeln();

  // show stats
  stdout.writeln('${sw.elapsed} - Array');
  stdout.writeln(arrayPerfs.stats.toString('   '));

  ///////// ASYNC PERFS - stream of random bytes /////////

  // run
  stdout.write('Async');
  final streamPerfs = StreamPerfRunner(5 * 512 * 1024);
  sw.reset();
  for (var i = 0; i < 10; i++) {
    stdout.write('.');
    await streamPerfs.run();
  }
  stdout.writeln();

  // show stats
  print('${sw.elapsed} - Stream');
  print(streamPerfs.stats.toString('   '));
}

abstract class PerfRunner {
  final stats = PerfStats();

  FutureOr<void> run();
}

class ArrayPerfRunner extends PerfRunner {
  ArrayPerfRunner(this.loops);

  final int loops;

  @override
  void run() {
    _measure('murmur3a - $Uint32_int_64bit_mul',
        MurmurHashV3(uint32: Uint32_int_64bit_mul.new).murmur3aSync);

    _measure('murmur3a - $Uint32_int_48bit_mul',
        MurmurHashV3(uint32: Uint32_int_48bit_mul.new).murmur3aSync);

    _measure('murmur3f - $Uint64_BigInt',
        MurmurHashV3(uint64: Uint64_BigInt.new).murmur3fSync);

    _measure('murmur3f - $Uint64_int',
        MurmurHashV3(uint64: Uint64_int.new).murmur3fSync);

    _measure('murmur3f - $Uint64_native',
        MurmurHashV3(uint64: Uint64_native.new).murmur3fSync);
  }

  void _measure<T>(String perfKey, HashFunctionSync<T> hash) {
    final seed = ((T == BigInt) ? BigInt.from(randomWord) : randomWord) as T;
    final sw = Stopwatch();
    var length = 0;
    for (var test in tests) {
      final bytes = MurmurHashV3.getBytes(test);
      for (var i = 0; i < loops; i++) {
        sw.start();
        hash(bytes, seed: seed);
        sw.stop();
        length += bytes.length;
      }
    }
    stats.update(perfKey, length, sw);
  }

  static final tests = [
    0,
    1,
    [0],
    [1],
    [0, 1, 2],
    Iterable.generate(128, (_) => randomByte),
    Iterable.generate(256, (_) => randomByte),
    true,
    false,
    'p@S5woRD!',
    '''I went to the Garden of Love,
And saw what I never had seen:
A Chapel was built in the midst,
Where I used to play on the green.

And the gates of this Chapel were shut,
And 'Thou shalt not' writ over the door;
So I turn'd to the Garden of Love,
That so many sweet flowers bore. 

And I saw it was filled with graves,
And tomb-stones where flowers should be:
And Priests in black gowns, were walking their rounds,
And binding with briars, my joys & desires.

-- William Blake''',
    '''Par les soirs bleus d'été, j'irai dans les sentiers,
Picoté par les blés, fouler l'herbe menue :
Rêveur, j'en sentirai la fraîcheur à mes pieds.
Je laisserai le vent baigner ma tête nue.

Je ne parlerai pas, je ne penserai rien :
Mais l'amour infini me montera dans l'âme,
Et j'irai loin, bien loin, comme un bohémien,
Par la Nature, – heureux comme avec une femme.

-- Arthur Rimbaud'''
  ];
}

class StreamPerfRunner extends PerfRunner {
  StreamPerfRunner(this.length);

  final int length;

  @override
  Future<void> run() async {
    await _measure('murmur3a - $Uint32_int_64bit_mul',
        MurmurHashV3(uint32: Uint32_int_64bit_mul.new).murmur3a);

    await _measure('murmur3a - $Uint32_int_48bit_mul',
        MurmurHashV3(uint32: Uint32_int_48bit_mul.new).murmur3a);

    await _measure('murmur3f - $Uint64_BigInt',
        MurmurHashV3(uint64: Uint64_BigInt.new).murmur3f);

    await _measure('murmur3f - $Uint64_int',
        MurmurHashV3(uint64: Uint64_int.new).murmur3f);

    await _measure('murmur3f - $Uint64_native',
        MurmurHashV3(uint64: Uint64_native.new).murmur3f);
  }

  Stream<Uint8List> _byteStream() async* {
    final min = 128, max = 64 * 1024;
    var remaining = length;
    while (remaining > min) {
      var chunk = min + rnd.nextInt(max - min + 1);
      if (chunk > remaining) chunk = remaining;
      remaining -= chunk;
      yield Uint8List.fromList(List.generate(chunk, (_) => randomByte));
    }
    if (remaining > 0) {
      yield Uint8List.fromList(List.generate(remaining, (_) => randomByte));
    }
  }

  Future<void> _measure<T>(String perfKey, HashFunction<T> hash) async {
    final seed = ((T == BigInt) ? BigInt.from(randomWord) : randomWord) as T;
    final stream = _byteStream();
    final sw = Stopwatch()..start();
    await hash(stream, seed: seed).whenComplete(sw.stop);
    stats.update(perfKey, length, sw);
  }
}

final rnd = Random();
int get randomByte => rnd.nextInt(0x100);
int get randomWord => rnd.nextInt(0x100000000);
