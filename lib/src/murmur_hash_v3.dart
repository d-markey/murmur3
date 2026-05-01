import 'dart:async';
import 'dart:typed_data';

import '_murmur_context.dart';
import 'type_exception.dart';
import 'uint.dart';

typedef HashFunction<T> = Future<T> Function(Object? data, {T? seed});
typedef HashFunction32 = HashFunction<int>;
typedef HashFunction128 = HashFunction<BigInt>;

typedef HashFunctionSync<T> = T Function(Object? data, {T? seed});
typedef HashFunctionSync32 = HashFunctionSync<int>;
typedef HashFunctionSync128 = HashFunctionSync<BigInt>;

/// MurmurHash3 for x64 (Little Endian).
/// Reference: https://en.wikipedia.org/wiki/MurmurHash
class MurmurHashV3 {
  const MurmurHashV3({FUint32? uint32, FUint64? uint64})
      : _uint32 = uint32 ?? Uint32_int_48bit_mul.new,
        _uint64 = uint64 ?? Uint64_int.new;

  ///////////////////////////////////
  //
  // 32-bit implementation (murmur3a)
  //
  ///////////////////////////////////

  final FUint32 _uint32;

  /// MurmurHash3 32-bit implementation.
  Future<int> murmur3a(Object? data, {int? seed}) {
    final context = MurmurContext3a(_uint32, seed ?? 0);
    return switch (data) {
      Stream() => context.hashStream(data),
      _ => Future.value(context.hash(data))
    };
  }

  int murmur3aSync(Object? data, {int? seed}) {
    if (data is Stream) {
      throw UnsupportedError('Streams cannot be hashed synchronously');
    }
    return MurmurContext3a(_uint32, seed ?? 0).hash(data);
  }

  ////////////////////////////////////////
  //
  // 128-bit x64 implementation (murmur3f)
  //
  ////////////////////////////////////////

  final FUint64 _uint64;

  /// MurmurHash3 128-bit x64 implementation, converting the input data via [_getBytes].
  // ignore: non_constant_identifier_names
  Future<BigInt> murmur3f(Object? data, {BigInt? seed}) {
    final context = MurmurContext3f(_uint64, seed ?? BigInt.zero);
    return switch (data) {
      Stream() => context.hashStream(data),
      _ => Future.value(context.hash(data))
    };
  }

  BigInt murmur3fSync(Object? data, {BigInt? seed}) {
    if (data is Stream) {
      throw UnsupportedError('Streams cannot be hashed synchronously');
    }
    return MurmurContext3f(_uint64, seed ?? BigInt.zero).hash(data);
  }

  /// Get bytes from [data]. Conversion depends on [data]'s type:
  /// * `null` --> returns `[]`.
  /// * [Uint8List] --> returns [data] as is.
  /// * [Iterable]<[num]> --> returns [data] as bytes, throwing a [TypeException] if data contains any non-byte value.
  /// * [num] --> returns an array containing [data] if it is a byte, otherwise throws a [TypeException].
  /// * [bool] --> returns `[1]` if [data] is `true`, `[0]` otherwise.
  /// * [String] --> returns an array containing [data]'s UTF-8 bytes.
  /// * [Iterable] --> returns an array containing all bytes obtained by applying [getBytes] to each item in [data].
  /// Otherwise, a [TypeException] is thrown.
  static Uint8List getBytes(Object? data) => MurmurContext.getBytes(data);
}
