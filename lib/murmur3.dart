import 'src/murmur_hash_v3.dart';

export 'src/murmur_hash_v3.dart';
export 'src/type_exception.dart';
export 'src/uint.dart';

/// Default [MurmurHashV3] instance. It uses [Uint32_int_48bit_mul] and [Uint64_int] (cross-platform).
const murmur3 = MurmurHashV3();

/// MurmurHash3 32-bit implementation.
/// The data is converted using [MurmurHashV3.getBytes].
final murmur3_32 = murmur3.murmur3a;

/// MurmurHash3 128-bit x64 implementation.
/// The data is converted using [MurmurHashV3.getBytes].
final murmur3_128x64 = murmur3.murmur3f;

/// MurmurHash3 32-bit implementation.
/// The data is converted using [MurmurHashV3.getBytes].
final murmur3a = murmur3.murmur3a;

/// MurmurHash3 128-bit x64 implementation.
/// The data is converted using [MurmurHashV3.getBytes].
final murmur3f = murmur3.murmur3f;
