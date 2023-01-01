import 'dart:async';

import 'package:murmur3/murmur3.dart';

import 'helpers/stats.dart';

typedef HashFunction = FutureOr Function(dynamic data, int seed);

void main() async {
  print('Platform uint32 is $Uint32_int_xplat');
  final os = (Uint32_int_xplat == Uint32_int_48bit_mul) ? 'browser' : 'vm';
  final loops = (Uint32_int_xplat == Uint32_int_48bit_mul) ? 2000 : 20000;

  // warm up
  run(PerfStats(), 10);

  // run
  final perfs = PerfStats();
  final sw = Stopwatch()..start();
  for (var i = 0; i < 10; i++) {
    await run(perfs, loops);
  }

  // show stats
  print('${sw.elapsed} - Array - $os');
  print(perfs);
}

Future run(PerfStats perfStats, int loops) async {
  MurmurHashV3.useUInt32Impl(Uint32_int_64bit_mul.new);
  await perfStats.measure('murmur3a', '$Uint32_int_64bit_mul', loops);

  MurmurHashV3.useUInt32Impl(Uint32_int_48bit_mul.new);
  await perfStats.measure('murmur3a', '$Uint32_int_48bit_mul', loops);

  MurmurHashV3.useUInt64Impl(Uint64_BigInt.new);
  await perfStats.measure('murmur3f', '$Uint64_BigInt', loops);

  MurmurHashV3.useUInt64Impl(Uint64_int.new);
  await perfStats.measure('murmur3f', '$Uint64_int', loops);
}

class PerfStats {
  final _algorithms = <String, HashFunction>{
    'murmur3a': (data, seed) => murmur3a(data, seed: seed),
    'murmur3f': (data, seed) => murmur3f(data, seed: seed),
  };

  final _stats = <String, Stats>{};

  void clear() => _stats.clear();

  void _add(String label, int length, Duration duration) {
    final stat = _stats.putIfAbsent(label, () => Stats(label));
    stat.add(length, duration);
  }

  Iterable<Stats> get stats => _stats.values;

  final tests = [
    0,
    1,
    [0],
    [1],
    [0, 1, 2],
    Iterable.generate(128),
    Iterable.generate(256),
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

  Future<void> measure(String algorithm, String variant, int loops) async {
    final hash = _algorithms[algorithm]!;
    final sw = Stopwatch();
    var length = 0;
    for (var test in tests) {
      final bytes = MurmurHashV3.getBytes(test);
      for (var i = 0; i < loops; i++) {
        sw.start();
        hash(bytes, i);
        sw.stop();
        length += bytes.length;
      }
    }
    _add('$algorithm - $variant', length, sw.elapsed);
  }

  @override
  String toString() =>
      _stats.entries.map((e) => '${e.key}: ${e.value}').join('\n');
}
