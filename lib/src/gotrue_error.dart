class GotrueError {
  String message;
  String? statusCode;

  GotrueError(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() {
    return 'GotrueError(message: $message, statusCode: $statusCode)';
  }
}
