enum FailureKind { network, timeout, server, notFound, invalidData, unexpected }

class AppFailure implements Exception {
  const AppFailure(this.kind, this.message, {this.statusCode});
  final FailureKind kind;
  final String message;
  final int? statusCode;
  @override
  String toString() =>
      'AppFailure($kind${statusCode == null ? '' : ', HTTP $statusCode'})';
}
