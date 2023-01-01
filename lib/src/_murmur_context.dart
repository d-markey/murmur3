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
  int _loadBlock(List<int> bytes, int offset);

  /// Processes a block.
  void _processBlock();

  /// Processes the tail if any (remaining bytes).
  void _processTail();

  /// Finalizes the hash computation.
  void _finalize();

  /// Synchronously process the data and returns the hash value.
  FutureOr<T> process(dynamic data) {
    _pending = 0;
    _length = 0;

    _handleBody(data);
    _handleTailAndFinalize();

    return getHash();
  }

  Completer<T>? _completer;

  /// Process the data as a [Stream] and returns the hash value.
  Future<T> processStream(Stream data) {
    _completer = Completer<T>();
    _pending = 0;
    _length = 0;

    final sub = data.listen(
      _handleBody,
      onDone: _handleTailAndFinalize,
      onError: _handleError,
      cancelOnError: true,
    );

    return _completer!.future.whenComplete(sub.cancel);
  }

  void _handleBody(dynamic input) {
    try {
      final bytes = getBytes(input);
      final len = bytes.length;
      var idx = 0;
      while (idx < len) {
        final count = _loadBlock(bytes, idx);
        _pending += count;
        _length += count;
        idx += count;
        if (_pending == blockSize) {
          _processBlock();
          _pending = 0;
        }
      }
    } catch (e, st) {
      if (_completer == null) {
        rethrow;
      } else {
        _completer!.completeError(e, st);
      }
    }
  }

  void _handleTailAndFinalize() {
    try {
      // process tail & finalize
      if (_pending > 0) {
        _pending = 0;
        _processTail();
      }
      _finalize();

      // done
      _completer?.complete(getHash());
    } catch (e, st) {
      if (_completer == null) {
        rethrow;
      } else {
        _completer!.completeError(e, st);
      }
    }
  }

  void _handleError(Object error, StackTrace st) {
    _completer!.completeError(error, st);
  }

  static Uint8List getBytes(dynamic data) {
    if (data is Uint8List) {
      return data;
    } else if (data is Iterable<num>) {
      return Uint8List.fromList(data.map(_getByte).toList());
    } else {
      return Uint8List.fromList(_getBytes(data).toList());
    }
  }

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
  static Iterable<int> _getBytes(dynamic data) sync* {
    if (data == null) {
      // yield nothing
    } else if (data is num) {
      yield _getByte(data);
    } else if (data is bool) {
      yield data ? 1 : 0;
    } else if (data is String) {
      yield* utf8.encode(data);
    } else if (data is Iterable) {
      for (var item in data) {
        yield* getBytes(item);
      }
    } else {
      throw TypeException('Unsupported data type: ${data.runtimeType}');
    }
  }
}
