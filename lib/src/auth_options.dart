class AuthOptions {
  final String? redirectTo;
  final String? scopes;

  AuthOptions({
    /// A URL or mobile address to send the user to after they are confirmed.
    this.redirectTo,

    /// A space-separated list of scopes granted to the OAuth application.
    this.scopes,
  });
}
