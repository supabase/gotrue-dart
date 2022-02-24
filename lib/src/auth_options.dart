import 'package:gotrue/gotrue.dart';

class AuthOptions {
  /// A URL or mobile address to send the user to after they are confirmed.
  final String? redirectTo;

  /// A space-separated list of scopes granted to the OAuth application.
  final String? scopes;

  /// Set [User.userMetadata] on sign up
  final Map<String, dynamic>? userMetadata;
  AuthOptions({
    this.redirectTo,
    this.scopes,
    this.userMetadata,
  });
}
