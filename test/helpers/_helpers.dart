import 'dart:math';

final intendedError = 'intended error ${DateTime.now().toUtc()}';

String hex(dynamic num, int bits) =>
    num.toRadixString(16).padLeft(bits ~/ 4, '0');

List splitWorkload(Iterable data) {
  final items = data.toList();
  final parts = [];
  final rnd = Random();
  while (items.isNotEmpty) {
    final p = items.take(rnd.nextInt(items.length + 1)).toList();
    if (p.isNotEmpty) {
      parts.add(p);
      items.removeRange(0, p.length);
    }
  }
  return parts;
}
