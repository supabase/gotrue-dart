import 'package:gotrue/src/types/user.dart';

import '../gotrue_mfa_api.dart';

class AuthMFAEnrollResponse {
  /// ID of the factor that was just enrolled (in an unverified state).
  final String id;

  /// Type of MFA factor. Only `totp` supported for now.
  final String type;

  /// TOTP enrollment information.
  final TOTPEnrollment totp;

  AuthMFAEnrollResponse({
    required this.id,
    required this.type,
    required this.totp,
  });
}

class TOTPEnrollment {
  ///Contains a QR code encoding the authenticator URI.
  ///
  ///You can convert it to a URL by prepending `data:image/svg+xml;utf-8,` to the value. Avoid logging this value to the console.
  final String qrCode;

  ///The TOTP secret (also encoded in the QR code).
  ///
  ///Show this secret in a password-style field to the user, in case they are unable to scan the QR code. Avoid logging this value to the console.
  final String secret;

  ///The authenticator URI encoded within the QR code, should you need to use it. Avoid logging this value to the console.
  final String uri;

  TOTPEnrollment({
    required this.qrCode,
    required this.secret,
    required this.uri,
  });
}

class AuthMFAChallengeResponse {
  /// ID of the newly created challenge.
  final String id;

  /// Timestamp when this challenge will no longer be usable.
  final DateTime expiresAt;

  AuthMFAChallengeResponse({required this.id, required this.expiresAt});
}

class AuthMFAVerifyResponse {
  /// New access token (JWT) after successful verification.
  final String accessToken;

  /// Type of token, typically `Bearer`.
  final String tokenType;

  /// Duration in which the access token will expire.
  final Duration expiresIn;

  /// Refresh token you can use to obtain new access tokens when expired.
  final String refreshToken;

  /// Updated user profile.
  final User user;

  AuthMFAVerifyResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.user,
  });
}

class AuthMFAUnenrollResponse {
  /// ID of the factor that was successfully unenrolled.
  final String id;

  AuthMFAUnenrollResponse({required this.id});
}

class AuthMFAListFactorsResponse {
  final List<Factor> all;
  final List<Factor> totp;

  AuthMFAListFactorsResponse({required this.all, required this.totp});
}

enum FactorStatus { verified, unverified }

enum FactorType { totp }

class Factor {
  /// ID of the factor.
  final String id;

  /// Friendly name of the factor, useful to disambiguate between multiple factors.
  final String friendlyName;

  /// Type of factor. Only `totp` supported with this version but may change in future versions.
  final FactorType factorType;

  /// Factor's status.
  final FactorStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  Factor({
    required this.id,
    required this.friendlyName,
    required this.factorType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum AuthenticatorAssuranceLevels { aal1, aal2 }

class AuthMFAGetAuthenticatorAssuranceLevelResponse {
  /// Current AAL level of the session.
  final AuthenticatorAssuranceLevels? currentLevel;

  /// Next possible AAL level for the session. If the next level is higher than the current one, the user should go through MFA.
  ///
  /// see [GoTrueMFAApi.challenge]
  final AuthenticatorAssuranceLevels? nextLevel;

  AuthMFAGetAuthenticatorAssuranceLevelResponse({
    required this.currentLevel,
    required this.nextLevel,
  });
}
