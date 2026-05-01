class PerfStats {
  final _stats = <String, Stats>{};

  void update(String label, int length, Stopwatch sw) {
    final stat = _stats.putIfAbsent(label, () => Stats(label));
    stat.add(length, sw.elapsedMicroseconds);
  }

  Iterable<Stats> get stats => _stats.values;

  @override
  String toString([String indent = '']) =>
      _stats.entries.map((e) => '$indent${e.key}: ${e.value}').join('\n');
}

class Stats {
  Stats(this.label);

  final String label;
  var microsecs = 0;
  var length = BigInt.zero;

  void add(int length, int microsecs) {
    this.microsecs += microsecs;
    this.length += BigInt.from(length);
  }

  @override
  String toString() {
    var mb = length.toDouble() / (1024 * 1024);
    var payload = length.toDouble();
    String volume;
    if (payload > 1000 * 1024 * 1024) {
      payload /= 1024 * 1024 * 1024;
      volume = '${payload.toStringAsFixed(3)} Gb';
    } else if (payload > 1000 * 1024) {
      payload /= 1024 * 1024;
      volume = '${payload.toStringAsFixed(2)} Mb';
    } else if (payload > 10 * 1024) {
      payload /= 1024;
      volume = '${payload.toStringAsFixed(1)} Kb';
    } else {
      volume = '$length bytes';
    }
    final throughput = (microsecs == 0)
        ? '-'
        : ((mb * 1000) / (microsecs / 1000)).toStringAsFixed(2);
    return '$volume in ${Duration(microseconds: microsecs)} / $throughput Mb/s';
  }
}
