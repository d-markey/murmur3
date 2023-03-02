import 'dart:async';
import 'dart:typed_data';

import '_murmur_context.dart';
import 'type_exception.dart';
import 'uint.dart';

/// MurmurHash3 for x64 (Little Endian).
/// Reference: https://en.wikipedia.org/wiki/MurmurHash
class MurmurHashV3 {
  ///////////////////////////////////
  //
  // 32-bit implementation (murmur3a)
  //
  ///////////////////////////////////

  /// Sets the IUInt64 implementation to use. Defaults to [Uint32_int_xplat.new].
  static void useUInt32Impl(IUint32 Function(int n) uint32) => _uint32 = uint32;

  static IUint32 Function(int n) _uint32 = Uint32_int_xplat.new;

  /// MurmurHash3 32-bit implementation.
  static FutureOr<int> murmur3a(dynamic data, {int seed = 0}) {
    final context = MurmurContext3a(_uint32, seed);
    return (data is Stream)
        ? context.processStream(data)
        : context.process(data);
  }

  ////////////////////////////////////////
  //
  // 128-bit x64 implementation (murmur3f)
  //
  ////////////////////////////////////////

  /// Sets the IUInt64 implementation to use. Defaults to [Uint64_int.new].
  static void useUInt64Impl(IUint64 Function(dynamic n) uint64) =>
      _uint64 = uint64;

  static IUint64 Function(dynamic n) _uint64 = Uint64_int.new;

  /// MurmurHash3 128-bit x64 implementation, converting the input data via [_getBytes].
  // ignore: non_constant_identifier_names
  static FutureOr<BigInt> murmur3f(dynamic data, {BigInt? seed}) {
    final context = MurmurContext3f(_uint64, seed ?? BigInt.zero);
    return (data is Stream)
        ? context.processStream(data)
        : context.process(data);
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
  static Uint8List getBytes(dynamic data) => MurmurContext.getBytes(data);
}
