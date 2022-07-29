class AuthOptions {
  /// A URL or mobile address to send the user to after they are confirmed.
  final String? redirectTo;

  /// A space-separated list of scopes granted to the OAuth application.
  final String? scopes;
  final String? captchaToken;

  const AuthOptions({
    this.redirectTo,
    this.scopes,
    this.captchaToken,
  });
}
