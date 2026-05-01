import 'type_exception.dart';
import 'uint.dart';

final mask64 = BigInt.parse('0xFFFFFFFFFFFFFFFF');
const mask32 = 0xFFFFFFFF;

int clamp32(int n) => n & mask32;

BigInt clamp64(BigInt n) =>
    (BigInt.zero <= n && n <= mask64) ? n : (n & mask64);

BigInt toBigInt(Object? value) => clamp64(switch (value) {
      BigInt() => value,
      IUint64() => value.value,
      String() => BigInt.parse(value),
      num() => BigInt.from(value),
      _ => throw TypeException('Cannot handle ${value.runtimeType}')
    });

Never unsupported64bit() =>
    throw Exception('Native 64-bit int is not supported on this platform.');

const $vmOrWasm =
    bool.fromEnvironment('dart.library.io', defaultValue: false) ||
        bool.fromEnvironment('dart.tool.dart2wasm', defaultValue: false);
