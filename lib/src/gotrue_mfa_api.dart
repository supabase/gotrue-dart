part of 'gotrue_client.dart';

class GoTrueMFAApi {
  final GoTrueClient client;
  final GotrueFetch fetch;
  GoTrueMFAApi(this.client, this.fetch);

  /// Starts the enrollment process for a new Multi-Factor Authentication (MFA)
  /// factor. This method creates a new `unverified` factor.
  /// To verify a factor, present the QR code or secret to the user and ask them to add it to their
  /// authenticator app.
  /// The user has to enter the code from their authenticator app to verify it.
  ///
  /// Upon verifying a factor, all other sessions are logged out and the current session's authenticator level is promoted to `aal2`.
  ///
  /// [factorType] : he type of factor being enrolled.
  /// [issuer] : Domain which the user is enrolled with.
  /// [friendlyName] : Human readable name assigned to the factor.
  Future<AuthMFAEnrollResponse> enroll({
    String factorType = "totp",
    String? issuer,
    String? friendlyName,
  }) {
    throw UnimplementedError();
  }

  /// Prepares a challenge used to verify that a user has access to a MFA factor.
  Future<AuthMFAChallengeResponse> challenge({
    required String factorId,
  }) {
    throw UnimplementedError();
  }

  /// Verifies a code against a [challengeId].
  ///
  /// The verification [code] is provided by the user by entering a code seen in their authenticator app.
  Future<AuthMFAVerifyResponse> verify({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    final session = client.currentSession;

    final data = await fetch.request(
        '${client._url}/factors/$factorId/verify', RequestMethodType.post,
        options: GotrueRequestOptions(
          headers: client._headers,
          body: {
            'challenge_id': challengeId,
            'code': code,
          },
          jwt: session?.accessToken,
        ));

    final response = AuthMFAVerifyResponse.fromJson(data);
    client._saveSession(
      Session(
        accessToken: response.accessToken,
        tokenType: response.tokenType,
        user: response.user,
        expiresIn: response.expiresIn.inSeconds,
        refreshToken: response.refreshToken,
      ),
    );
    client._notifyAllSubscribers(AuthChangeEvent.mfaChallengeVerified);
    return response;
  }

  /// Unenroll removes a MFA factor.
  ///
  /// A user has to have an `aal2` authenticator level in order to unenroll a `verified` factor.
  Future<AuthMFAUnenrollResponse> unenroll(String factorId) {
    throw UnimplementedError();
  }

  /// Helper method which creates a challenge and immediately uses the given code to verify against it thereafter.
  ///
  /// The verification code is provided by the user by entering a code seen in their authenticator app.
  Future<AuthMFAVerifyResponse> challengeAndVerify({
    required String factorId,
    required String code,
  }) {
    throw UnimplementedError();
  }

  /// Returns the list of MFA factors enabled for this user. For most use cases
  /// you should consider using [GoTrueMFAApi.getAuthenticatorAssuranceLevel]. This uses a cached version
  /// of the factors and avoids incurring a network call. If you need to update
  /// this list, call [GoTrueClient.currentUser] first.
  ///
  /// see [GoTrueMFAApi.enroll]
  /// see [GoTrueMFAApi.getAuthenticatorAssuranceLevel]
  /// see [GoTrueClient.currentUser]
  Future<AuthMFAListFactorsResponse> listFactors() {
    throw UnimplementedError();
  }

  /// Returns the Authenticator Assurance Level (AAL) for the active session.
  ///
  /// - `aal1` (or `null`) means that the user's identity has been verified only
  /// with a conventional login (email+password, OTP, magic link, social login,
  /// etc.).
  /// - `aal2` means that the user's identity has been verified both with a conventional login and at least one MFA factor.
  ///
  /// Although this method returns a promise, it's fairly quick (microseconds)
  /// and rarely uses the network. You can use this to check whether the current
  /// user needs to be shown a screen to verify their MFA factors.
  ///
  Future<AuthMFAGetAuthenticatorAssuranceLevelResponse>
      getAuthenticatorAssuranceLevel() {
    throw UnimplementedError();
  }
}
