class Stats {
  Stats(this.label);

  final String label;
  var duration = Duration.zero;
  var length = BigInt.zero;

  void add(int length, Duration duration) {
    this.duration += duration;
    this.length += BigInt.from(length);
  }

  @override
  String toString() {
    var mb = length.toDouble() / (1024 * 1024);
    var payload = length.toDouble();
    var volume = '$length bytes';
    if (payload > 1000 * 1024 * 1024) {
      payload /= 1024 * 1024 * 1024;
      volume = '${payload.toStringAsFixed(3)} Gb';
    } else if (payload > 1000 * 1024) {
      payload /= 1024 * 1024;
      volume = '${payload.toStringAsFixed(2)} Mb';
    } else if (payload > 10 * 1024) {
      payload /= 1024;
      volume = '${payload.toStringAsFixed(1)} Kb';
    }
    final throughput = (duration.inMilliseconds == 0)
        ? '-'
        : ((mb * 1000) / duration.inMilliseconds).toStringAsFixed(2);
    return '$volume in $duration / $throughput Mb/s';
  }
}
