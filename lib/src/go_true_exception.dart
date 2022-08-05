class GoTrueException {
  final String message;
  final String? statusCode;

  GoTrueException(this.message, {this.statusCode});

  @override
  String toString() =>
      'GoTrueException(message: $message, statusCode: $statusCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoTrueException &&
        other.message == message &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;
}
