/// Mummur3 library
library murmur3;

export 'src/murmur_hash_v3.dart';
export 'src/type_exception.dart';
export 'src/uint.dart';

import 'src/murmur_hash_v3.dart';

/// MurmurHash3 32-bit implementation.
/// The data is converted using [MurmurHashV3.getBytes].
const murmur3_32 = MurmurHashV3.murmur3a;

/// MurmurHash3 128-bit x64 implementation.
/// The data is converted using [MurmurHashV3.getBytes].
const murmur3_128x64 = MurmurHashV3.murmur3f;

/// MurmurHash3 32-bit implementation.
/// The data is converted using [MurmurHashV3.getBytes].
const murmur3a = MurmurHashV3.murmur3a;

/// MurmurHash3 128-bit x64 implementation.
/// The data is converted using [MurmurHashV3.getBytes].
const murmur3f = MurmurHashV3.murmur3f;
