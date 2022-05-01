class GotrueError {
  final String message;

  GotrueError(this.message);

  @override
  String toString() => 'GotrueError(message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GotrueError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
