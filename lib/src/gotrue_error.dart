class GotrueError {
  final String message;
  final String? statusCode;

  GotrueError(this.message, {this.statusCode});

  @override
  String toString() =>
      'GotrueError(message: $message, statusCode: $statusCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GotrueError &&
        other.message == message &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;
}
