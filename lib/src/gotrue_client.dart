import 'dart:async';
import 'dart:convert';

import 'constants.dart';
import 'cookie_options.dart';
import 'gotrue_api.dart';
import 'gotrue_error.dart';
import 'gotrue_response.dart';
import 'provider.dart';
import 'session.dart';
import 'subscription.dart';
import 'user.dart';
import 'user_attributes.dart';
import 'uuid.dart';

class GoTrueClient {
  /// Namespace for the GoTrue API methods.
  /// These can be used for example to get a user from a JWT in a server environment or reset a user's password.
  late GoTrueApi api;

  /// The currently logged in user or null.
  User? currentUser;

  /// The session object for the currently logged in user or null.
  Session? currentSession;

  late bool autoRefreshToken;
  Map<String, Subscription> stateChangeEmitters = {};

  Timer? _refreshTokenTimer;

  GoTrueClient(
      {String? url,
      Map<String, String>? headers,
      bool? autoRefreshToken,
      CookieOptions? cookieOptions}) {
    this.autoRefreshToken = autoRefreshToken ?? true;

    final _url = url ?? Constants.defaultGotrueUrl;
    final _header = headers ?? Constants.defaultHeaders;
    api = GoTrueApi(_url, headers: _header, cookieOptions: cookieOptions);
  }

  /// Returns the user data, if there is a logged in user.
  User? user() {
    return currentUser;
  }

  /// Returns the session data, if there is an active session.
  Session? session() {
    return currentSession;
  }

  /// Creates a new user.
  Future<GotrueSessionResponse> signUp(String email, String password) async {
    _removeSession();

    final response = await api.signUpWithEmail(email, password);
    if (response.error != null) return response;

    if (response.data?.user?.confirmedAt != null) {
      _saveSession(response.data!);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  /// Log in an existing user, or login via a third-party provider.
  Future<GotrueSessionResponse> signIn(
      {String? email,
      String? password,
      Provider? provider,
      ProviderOptions? options}) async {
    _removeSession();

    if (email != null) {
      if (password == null) {
        final response = await api.sendMagicLinkEmail(email);
        return GotrueSessionResponse(error: response.error);
      } else {
        return _handleEmailSignIn(email, password);
      }
    } else if (provider != null) {
      return _handleProviderSignIn(provider, options);
    } else {
      final error = GotrueError(
          "You must provide either an email or a third-party provider.");
      return GotrueSessionResponse(error: error);
    }
  }

  /// Force refreshes the session including the user data in case it was updated in a different session.
  Future<GotrueSessionResponse> refreshSession() async {
    if (currentSession?.accessToken == null) {
      final error = GotrueError('Not logged in.');
      return GotrueSessionResponse(error: error);
    }

    final response = await _callRefreshToken();
    return response;
  }

  /// Gets the session data from a oauth2 callback URL
  Future<GotrueSessionResponse> getSessionFromUrl(Uri originUrl,
      {bool storeSession = true}) async {
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
      return GotrueSessionResponse(error: GotrueError(errorDescription));
    }

    final accessToken = url.queryParameters['access_token'];
    final expiresIn = url.queryParameters['expires_in'];
    final refreshToken = url.queryParameters['refresh_token'];
    final tokenType = url.queryParameters['token_type'];
    final providerToken = url.queryParameters['provider_token'];

    if (accessToken == null) {
      return GotrueSessionResponse(
          error: GotrueError('No access_token detected.'));
    }
    if (expiresIn == null) {
      return GotrueSessionResponse(
          error: GotrueError('No expires_in detected.'));
    }
    if (refreshToken == null) {
      return GotrueSessionResponse(
          error: GotrueError('No refresh_token detected.'));
    }
    if (tokenType == null) {
      return GotrueSessionResponse(
          error: GotrueError('No token_type detected.'));
    }

    final response = await api.getUser(accessToken);
    if (response.error != null) {
      return GotrueSessionResponse(error: response.error);
    }

    final session = Session(
        accessToken: accessToken,
        expiresIn: int.parse(expiresIn),
        refreshToken: refreshToken,
        tokenType: tokenType,
        providerToken: providerToken,
        user: response.user);

    if (storeSession == true) {
      _saveSession(session);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
      final type = url.queryParameters['type'];
      if (type == 'recovery') {
        _notifyAllSubscribers(AuthChangeEvent.passwordRecovery);
      }
    }

    return GotrueSessionResponse(data: session);
  }

  /// Updates user data, if there is a logged in user.
  Future<GotrueUserResponse> update(UserAttributes attributes) async {
    if (currentSession?.accessToken == null) {
      final error = GotrueError('Not logged in.');
      return GotrueUserResponse(error: error);
    }

    final response =
        await api.updateUser(currentSession!.accessToken, attributes);
    if (response.error != null) return response;

    currentUser = response.user;
    _notifyAllSubscribers(AuthChangeEvent.userUpdated);

    return response;
  }

  /// Signs out the current user, if there is a logged in user.
  Future<GotrueResponse> signOut() async {
    final accessToken = currentSession?.accessToken;
    _removeSession();
    _notifyAllSubscribers(AuthChangeEvent.signedOut);
    if (accessToken != null) {
      final response = await api.signOut(accessToken);
      if (response.error != null) return response;
    }
    return GotrueResponse();
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
        });
    stateChangeEmitters[id] = subscription;
    return GotrueSubscription(data: subscription);
  }

  /// Recover session from persisted session json string.
  /// Persisted session json has the format { currentSession, expiresAt }
  ///
  /// currentSession: session json object, expiresAt: timestamp in seconds
  Future<GotrueSessionResponse> recoverSession(String jsonStr) async {
    try {
      final persistedData = json.decode(jsonStr) as Map<String, dynamic>;
      final currentSession =
          persistedData['currentSession'] as Map<String, dynamic>?;
      final expiresAt = persistedData['expiresAt'] as int?;
      if (currentSession == null) {
        return GotrueSessionResponse(
            error: GotrueError('Missing currentSession.'));
      }
      if (expiresAt == null) {
        return GotrueSessionResponse(error: GotrueError('Missing expiresAt.'));
      }

      final session = Session.fromJson(currentSession);
      if (session.user == null) {
        return GotrueSessionResponse(
            error: GotrueError('Current session is missing data.'));
      }

      final timeNow = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      if (expiresAt < timeNow) {
        if (autoRefreshToken && session.refreshToken != null) {
          final response =
              await _callRefreshToken(refreshToken: session.refreshToken);
          return response;
        } else {
          return GotrueSessionResponse(error: GotrueError('Session expired.'));
        }
      } else {
        _saveSession(session);
        return GotrueSessionResponse(data: session);
      }
    } catch (e) {
      return GotrueSessionResponse(error: GotrueError(e.toString()));
    }
  }

  Future<GotrueSessionResponse> _handleEmailSignIn(
      String email, String password) async {
    final response = await api.signInWithEmail(email, password);
    if (response.error != null) return response;

    if (response.data?.user?.confirmedAt != null) {
      _saveSession(response.data!);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  /// return provider url only
  GotrueSessionResponse _handleProviderSignIn(
      Provider provider, ProviderOptions? options) {
    final url = api.getUrlForProvider(provider, options);
    return GotrueSessionResponse(provider: provider.name(), url: url);
  }

  void _saveSession(Session session) {
    currentSession = session;
    currentUser = session.user;
    final tokenExpirySeconds = session.expiresIn;

    if (autoRefreshToken && tokenExpirySeconds != null) {
      if (_refreshTokenTimer != null) _refreshTokenTimer!.cancel();

      final timerDuration = Duration(seconds: tokenExpirySeconds - 60);
      _refreshTokenTimer = Timer(timerDuration, () {
        _callRefreshToken();
      });
    }
  }

  void _removeSession() {
    currentSession = null;
    currentUser = null;
  }

  Future<GotrueSessionResponse> _callRefreshToken(
      {String? refreshToken}) async {
    final token = refreshToken ?? currentSession?.refreshToken;
    if (token == null) {
      final error = GotrueError('No current session.');
      return GotrueSessionResponse(error: error);
    }

    final response = await api.refreshAccessToken(token);
    if (response.error != null) return response;

    if (response.data?.accessToken != null) {
      _saveSession(response.data!);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  void _notifyAllSubscribers(AuthChangeEvent event) {
    stateChangeEmitters.forEach((k, v) => v.callback(event, currentSession));
  }
}
