class HttpAuthException implements Exception {
  final String message;

  HttpAuthException(this.message);

  @override
  String toString() {
    return message;
  }
}