import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'type_exception.dart';
import 'uint.dart';

part '_murmur_context_3a.dart';
part '_murmur_context_3f.dart';

abstract class MurmurContext<T> {
  /// Creates a new Murmur3 context.
  MurmurContext(this.blockSize);

  /// The block size for this murmur3 context.
  final int blockSize;

  /// The total length processed, in bytes.
  int _length = 0;

  /// Returns the number of pending bytes.
  int _pending = 0;

  /// The hash value.
  T getHash();

  /// Loads a block. Returns the number of bytes used.
  int _loadBlock(ByteData bytes, int offset);

  /// Processes a block.
  void _processBlock();

  /// Processes the tail if any (remaining bytes).
  void _processTail();

  /// Finalizes the hash computation.
  void _finalize();

  Completer<T>? _completer;

  /// Synchronously process the data and returns the hash value.
  T hash(Object? data) {
    if (_completer != null) {
      throw UnsupportedError('Cannot hash data in parallel.');
    }

    _pending = 0;
    _length = 0;

    _handleBody(data);
    _handleTailAndFinalize();

    return getHash();
  }

  /// Process the data as a [Stream] and returns the hash value.
  Future<T> hashStream(Stream<Object?> data) {
    if (_completer != null) {
      throw UnsupportedError('Cannot hash data in parallel.');
    }
    final completer = _completer = Completer<T>();

    void $handleBody(Object? input) {
      try {
        _handleBody(input);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    }

    void $handleTailAndFinalize() {
      try {
        // process tail & finalize
        _handleTailAndFinalize();
        completer.complete(getHash());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    }

    _pending = 0;
    _length = 0;

    final sub = data.listen(
      $handleBody,
      onDone: $handleTailAndFinalize,
      onError: completer.completeError,
      cancelOnError: true,
    );

    return completer.future.whenComplete(sub.cancel);
  }

  void _handleBody(Object? input) {
    final bytes = getBytesData(input), len = bytes.lengthInBytes;
    var idx = 0;

    // Finish current partial block
    if (_pending > 0) {
      while (idx < len && _pending < blockSize) {
        final count = _loadBlock(bytes, idx);
        _pending += count;
        idx += count;
      }
      if (_pending == blockSize) {
        _processBlock();
        _pending = 0;
      }
    }

    // Process full blocks directly
    while (len - idx >= blockSize) {
      _loadBlock(bytes, idx);
      _processBlock();
      idx += blockSize;
    }

    // Load pending partial block
    while (idx < len) {
      final count = _loadBlock(bytes, idx);
      _pending += count;
      idx += count;
    }

    // Update length
    _length += len;
  }

  void _handleTailAndFinalize() {
    // process tail & finalize
    if (_pending > 0) {
      _pending = 0;
      _processTail();
    }
    _finalize();
  }

  static ByteData getBytesData(Object? data) =>
      getBytes(data).buffer.asByteData();

  static final _empty = Uint8List(0);
  static final _false = Uint8List.fromList([0]);
  static final _true = Uint8List.fromList([1]);

  static Uint8List getBytes(Object? data) => switch (data) {
        null => _empty,
        bool() => data ? _true : _false,
        num() => Uint8List(1)..[0] = _getByte(data),
        Uint8List() => data,
        String() => utf8.encode(data),
        Iterable<num>() => Uint8List.fromList(data.map(_getByte).toList()),
        _ => Uint8List.fromList(_getBytes(data).toList())
      };

  static int _getByte(num n) {
    final i = n.isFinite ? n.toInt() : -1;
    if (i < 0 || i > 255 || (n is double && n != i)) {
      throw TypeException('Not a byte: $n');
    }
    return i;
  }

  /// Get bytes from [data]. Conversion depends on [data]'s type:
  /// * `null` --> yields nothing.
  /// * [Uint8List] --> yields all bytes from [data].
  /// * [num] --> yields [data] if it is a byte, otherwise throws a [TypeException].
  /// * [bool] --> yields `1` if [data] is `true`, `0` otherwise.
  /// * [String] --> yields the string's UTF-8 bytes.
  /// * [Iterable] --> yields all bytes obtained by applying [getBytes] to each item in [data].
  /// Otherwise, a [TypeException] is thrown.
  static Iterable<int> _getBytes(Object? data) sync* {
    switch (data) {
      case null:
        break;
      case num():
        yield _getByte(data);
      case bool():
        yield data ? 1 : 0;
      case String():
        yield* utf8.encode(data);
      case Iterable():
        for (var item in data) {
          yield* getBytes(item);
        }
      default:
        throw TypeException('Unsupported data type: ${data.runtimeType}');
    }
  }
}
