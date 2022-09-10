import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/constants.dart';
import 'package:gotrue/src/subscription.dart';
import 'package:gotrue/src/uuid.dart';
import 'package:http/http.dart';
import 'package:universal_io/io.dart';

class GoTrueClient {
  /// Namespace for the GoTrue API methods.
  /// These can be used for example to get a user from a JWT in a server environment or reset a user's password.
  late GoTrueApi api;

  /// The currently logged in user or null.
  User? _currentUser;

  /// The session object for the currently logged in user or null.
  Session? _currentSession;

  late bool autoRefreshToken;
  Map<String, Subscription> stateChangeEmitters = {};

  Timer? _refreshTokenTimer;

  int _refreshTokenRetryCount = 0;

  GoTrueClient({
    String? url,
    Map<String, String>? headers,
    bool? autoRefreshToken,
    CookieOptions? cookieOptions,
    Client? httpClient,
  }) {
    this.autoRefreshToken = autoRefreshToken ?? true;

    final gotrueUrl = url ?? Constants.defaultGotrueUrl;
    final gotrueHeader = {
      ...Constants.defaultHeaders,
      if (headers != null) ...headers,
    };
    api = GoTrueApi(
      gotrueUrl,
      headers: gotrueHeader,
      cookieOptions: cookieOptions,
      httpClient: httpClient,
    );
  }

  /// Returns the current logged in user, if any;
  User? get currentUser => _currentUser;

  /// Returns the current session, if any;
  Session? get currentSession => _currentSession;

  /// Creates a new user.
  ///
  /// [email] is the user's email address
  ///
  /// [phone] is the user's phone number WITH international prefix
  ///
  /// [password] is the password of the user
  ///
  /// [userMetadata] sets [User.userMetadata] without an extra call to [update]
  Future<GotrueSessionResponse> signUp({
    String? email,
    String? phone,
    required String password,
    AuthOptions? options,
    Map<String, dynamic>? userMetadata,
  }) async {
    assert((email != null && phone == null) || (email == null && phone != null),
        'You must provide either an email or phone number');

    _removeSession();

    late final GotrueSessionResponse response;

    if (email != null) {
      response = await api.signUpWithEmail(
        email,
        password,
        options: options,
        userMetadata: userMetadata,
      );
    } else if (phone != null) {
      response = await api.signUpWithPhone(phone, password,
          options: options, userMetadata: userMetadata);
      if (response.session == null) {
        throw GoTrueException('An error occurred on sign up.');
      }
    } else {
      throw GoTrueException(
          'You must provide either an email or phone number and a password');
    }

    final session = response.session;
    if (session != null) {
      _saveSession(session);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  /// Log in an existing user with an email and password or phone and password.
  Future<GotrueSessionResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    _removeSession();

    if (email != null) {
      return _handleEmailSignIn(email, password,
          options: AuthOptions(captchaToken: captchaToken));
    }
    if (phone != null) {
      return _handlePhoneSignIn(phone, password);
    }
    throw GoTrueException(
      'You must provide either an email, phone number, a third-party provider or OpenID Connect.',
    );
  }

  /// Log in an existing user via a third-party provider.
  Future<GotrueSessionResponse> signInWithOAuth({
    Provider? provider,
    AuthOptions? options,
  }) async {
    _removeSession();

    if (provider != null) {
      return _handleProviderSignIn(provider, options);
    }
    throw GoTrueException(
      'You must provide either an email, phone number, a third-party provider or OpenID Connect.',
    );
  }

  void some() {
    signInWithOtp(email: '');
  }

  /// Log in a user using magiclink or a one-time password (OTP).
  ///
  /// If the `{{ .ConfirmationURL }}` variable is specified in the email template, a magiclink will be sent.
  ///
  /// If the `{{ .Token }}` variable is specified in the email template, an OTP will be sent.
  ///
  /// If you're using phone sign-ins, only an OTP will be sent. You won't be able to send a magiclink for phone sign-ins.
  ///
  /// If [shouldCreateUser] is set to false, this method will not create a new user. Defaults to true.
  ///
  /// [emailRedirectTo] can be used to specify the redirect URL embedded in the email link
  Future<GotrueSessionResponse> signInWithOtp({
    String? email,
    String? phone,
    String? emailRedirectTo,
    bool? shouldCreateUser,
    String? captchaToken,
  }) async {
    _removeSession();

    if (email != null) {
      await api.sendMagicLinkEmail(
        email,
        shouldCreateUser: shouldCreateUser,
        options: AuthOptions(
          redirectTo: emailRedirectTo,
          captchaToken: captchaToken,
        ),
      );
      return GotrueSessionResponse();
    }
    if (phone != null) {
      await api.sendMobileOTP(
        phone,
        shouldCreateUser: shouldCreateUser,
        options: AuthOptions(
          captchaToken: captchaToken,
        ),
      );
      return GotrueSessionResponse();
    }
    throw GoTrueException(
      'You must provide either an email, phone number, a third-party provider or OpenID Connect.',
    );
  }

  /// Log in a user given a User supplied OTP received via mobile.
  ///
  /// [phone] is the user's phone number WITH international prefix
  ///
  /// [token] is the token that user was sent to their mobile phone
  Future<GotrueSessionResponse> verifyOTP(
    String phone,
    String token, {
    AuthOptions? options,
  }) async {
    _removeSession();

    final response = await api.verifyMobileOTP(phone, token, options: options);

    if (response.session == null) {
      throw GoTrueException(
        'An error occurred on token verification.',
      );
    }

    _saveSession(response.session!);
    _notifyAllSubscribers(AuthChangeEvent.signedIn);

    return response;
  }

  /// Force refreshes the session including the user data in case it was updated
  /// in a different session.
  Future<GotrueSessionResponse> refreshSession() async {
    final refreshCompleter = Completer<GotrueSessionResponse>();
    if (currentSession?.accessToken == null) {
      throw GoTrueException('Not logged in.');
    }

    final response = await _callRefreshToken(refreshCompleter);
    return response;
  }

  /// Sets the session data from refresh_token and returns the current session.
  Future<GotrueSessionResponse> setSession(String refreshToken) async {
    final refreshCompleter = Completer<GotrueSessionResponse>();
    if (refreshToken.isEmpty) {
      throw GoTrueException('No current session.');
    }
    return _callRefreshToken(refreshCompleter, refreshToken: refreshToken);
  }

  /// Overrides the JWT on the current client. The JWT will then be sent in all subsequent network requests.
  Session setAuth(String accessToken) {
    return _currentSession =
        _currentSession?.copyWith(accessToken: accessToken) ??
            Session(accessToken: accessToken, tokenType: 'bearer');
  }

  /// Gets the session data from a oauth2 callback URL
  Future<GotrueSessionResponse> getSessionFromUrl(
    Uri originUrl, {
    bool storeSession = true,
  }) async {
    var url = originUrl;
    if (originUrl.hasQuery) {
      final decoded = originUrl.toString().replaceAll('#', '&');
      url = Uri.parse(decoded);
    } else {
      final decoded = originUrl.toString().replaceAll('#', '?');
      url = Uri.parse(decoded);
    }

    final errorDescription = url.queryParameters['error_description'];
    if (errorDescription != null) {
      throw GoTrueException(errorDescription);
    }

    final accessToken = url.queryParameters['access_token'];
    final expiresIn = url.queryParameters['expires_in'];
    final refreshToken = url.queryParameters['refresh_token'];
    final tokenType = url.queryParameters['token_type'];
    final providerToken = url.queryParameters['provider_token'];

    if (accessToken == null) {
      throw GoTrueException('No access_token detected.');
    }
    if (expiresIn == null) {
      throw GoTrueException('No expires_in detected.');
    }
    if (refreshToken == null) {
      throw GoTrueException('No refresh_token detected.');
    }
    if (tokenType == null) {
      throw GoTrueException('No token_type detected.');
    }

    final response = await api.getUser(accessToken);

    final session = Session(
      accessToken: accessToken,
      expiresIn: int.parse(expiresIn),
      refreshToken: refreshToken,
      tokenType: tokenType,
      providerToken: providerToken,
      user: response.user,
    );

    if (storeSession == true) {
      _saveSession(session);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
      final type = url.queryParameters['type'];
      if (type == 'recovery') {
        _notifyAllSubscribers(AuthChangeEvent.passwordRecovery);
      }
    }

    return GotrueSessionResponse(session: session);
  }

  /// Updates user data, if there is a logged in user.
  Future<GotrueUserResponse> update(UserAttributes attributes) async {
    if (currentSession?.accessToken == null) {
      throw GoTrueException('Not logged in.');
    }

    final response =
        await api.updateUser(currentSession!.accessToken, attributes);
    // if (response.error != null) return response;

    _currentUser = response.user;
    _currentSession = currentSession?.copyWith(user: response.user);
    _notifyAllSubscribers(AuthChangeEvent.userUpdated);

    return response;
  }

  /// Signs out the current user, if there is a logged in user.
  Future<GotrueResponse> signOut() async {
    final accessToken = currentSession?.accessToken;
    _removeSession();
    _notifyAllSubscribers(AuthChangeEvent.signedOut);
    if (accessToken != null) {
      return api.signOut(accessToken);
    }
    return const GotrueResponse();
  }

  // Receive a notification every time an auth event happens.
  GotrueSubscription onAuthStateChange(Callback callback) {
    final id = uuid.generateV4();
    final GoTrueClient self = this;
    final subscription = Subscription(
      id: id,
      callback: callback,
      unsubscribe: () {
        self.stateChangeEmitters.remove(id);
      },
    );
    stateChangeEmitters[id] = subscription;
    return GotrueSubscription(data: subscription);
  }

  /// Recover session from persisted session json string.
  /// Persisted session json has the format { currentSession, expiresAt }
  ///
  /// currentSession: session json object, expiresAt: timestamp in seconds
  Future<GotrueSessionResponse> recoverSession(String jsonStr) async {
    final refreshCompleter = Completer<GotrueSessionResponse>();
    final persistedData = json.decode(jsonStr) as Map<String, dynamic>;
    final currentSession =
        persistedData['currentSession'] as Map<String, dynamic>?;
    final expiresAt = persistedData['expiresAt'] as int?;
    if (currentSession == null) {
      throw GoTrueException('Missing currentSession.');
    }
    if (expiresAt == null) {
      throw GoTrueException('Missing expiresAt.');
    }

    final session = Session.fromJson(currentSession);
    if (session.user == null) {
      throw GoTrueException('Current session is missing data.');
    }

    final timeNow = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    if (expiresAt < (timeNow - Constants.expiryMargin.inSeconds)) {
      if (autoRefreshToken && session.refreshToken != null) {
        final response = await _callRefreshToken(
          refreshCompleter,
          refreshToken: session.refreshToken,
          accessToken: session.accessToken,
        );
        return response;
      } else {
        throw GoTrueException('Session expired.');
      }
    } else {
      _saveSession(session);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
      return GotrueSessionResponse(session: session);
    }
  }

  Future<GotrueSessionResponse> _handleEmailSignIn(
    String email,
    String password, {
    AuthOptions? options,
  }) async {
    final response =
        await api.signInWithEmail(email, password, options: options);
    // if (response.error != null) return response;

    // ignore: deprecated_member_use_from_same_package
    if (response.session?.user?.confirmedAt != null ||
        response.session?.user?.emailConfirmedAt != null) {
      _saveSession(response.session!);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  /// return provider url only
  GotrueSessionResponse _handleProviderSignIn(
    Provider provider,
    AuthOptions? options,
  ) {
    final url = api.getUrlForProvider(provider, options);
    return GotrueSessionResponse(provider: provider.name(), url: url);
  }

  Future<GotrueSessionResponse> _handleOpenIDConnectSignIn(
    OpenIDConnectCredentials oidc,
  ) async {
    if ((oidc.clientId != null && oidc.issuer != null) ||
        oidc.provider != null) {
      final response = await api.signInWithOpenIDConnect(oidc);

      // if (response.error != null) return response;

      _saveSession(response.session!);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);

      return response;
    }
    throw GoTrueException(
      'You must provider an OpenID Connect clientID and issuer or provider.',
    );
  }

  Future<GotrueSessionResponse> _handlePhoneSignIn(
    String phone, [
    String? password,
  ]) async {
    final response = await api.signInWithPhone(phone, password);

    // if (response.error != null) return response;

    if (response.session?.user?.phoneConfirmedAt != null) {
      _saveSession(response.session!);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  void _saveSession(Session session) {
    final refreshCompleter = Completer<GotrueSessionResponse>();
    _currentSession = session;
    _currentUser = session.user;
    final expiresAt = session.expiresAt;

    if (autoRefreshToken && expiresAt != null) {
      _refreshTokenTimer?.cancel();

      final timeNow = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      final expiresIn = expiresAt - timeNow;
      final refreshDurationBeforeExpires = expiresIn > 60 ? 60 : 1;
      final nextDuration = expiresIn - refreshDurationBeforeExpires;
      if (nextDuration > 0) {
        final timerDuration = Duration(seconds: nextDuration);
        _setTokenRefreshTimer(timerDuration, refreshCompleter);
      } else {
        _callRefreshToken(refreshCompleter);
      }
    }
  }

  void _setTokenRefreshTimer(
    Duration timerDuration,
    Completer<GotrueSessionResponse> completer, {
    String? refreshToken,
    String? accessToken,
  }) {
    _refreshTokenTimer?.cancel();
    _refreshTokenRetryCount++;
    if (_refreshTokenRetryCount < Constants.maxRetryCount) {
      _refreshTokenTimer = Timer(timerDuration, () {
        _callRefreshToken(
          completer,
          refreshToken: refreshToken,
          accessToken: accessToken,
        );
      });
    } else {
      final error =
          GoTrueException('Access token refresh retry limit exceded.');
      completer.completeError(error, StackTrace.current);
    }
  }

  void _removeSession() {
    _currentSession = null;
    _currentUser = null;

    _refreshTokenTimer?.cancel();
  }

  Future<GotrueSessionResponse> _callRefreshToken(
    Completer<GotrueSessionResponse> completer, {
    String? refreshToken,
    String? accessToken,
  }) async {
    final token = refreshToken ?? currentSession?.refreshToken;
    if (token == null) {
      final error = GoTrueException('No current session.');
      completer.completeError(error, StackTrace.current);
      throw error;
    }

    final jwt = accessToken ?? currentSession?.accessToken;

    try {
      final response = await api.refreshAccessToken(token, jwt);
      if (response.session == null) {
        final error = GoTrueException('Invalid session data.');
        completer.completeError(error, StackTrace.current);
        throw error;
      }
      _refreshTokenRetryCount = 0;

      _saveSession(response.session!);
      _notifyAllSubscribers(AuthChangeEvent.tokenRefreshed);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);

      completer.complete(response);
      return completer.future;
    } on SocketException {
      _setTokenRefreshTimer(
        Constants.retryInterval * pow(2, _refreshTokenRetryCount),
        completer,
        refreshToken: refreshToken,
        accessToken: accessToken,
      );
      return completer.future;
    } catch (error, stack) {
      completer.completeError(error, stack);
      return completer.future;
    }
  }

  void _notifyAllSubscribers(AuthChangeEvent event) {
    stateChangeEmitters.forEach((k, v) => v.callback(event, currentSession));
  }
}
