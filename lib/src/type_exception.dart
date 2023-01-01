/// Exception thrown when the data type is not supported.
class TypeException implements Exception {
  TypeException([this.message = '']);

  final String message;

  @override
  String toString() =>
      message.isEmpty ? 'TypeException' : 'TypeException: $message';
}
