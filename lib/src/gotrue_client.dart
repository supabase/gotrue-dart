import 'dart:async';

import 'constants.dart';
import 'cookie_options.dart';
import 'gotrue_api.dart';
import 'gotrue_error.dart';
import 'gotrue_response.dart';
import 'session.dart';
import 'storage.dart';
import 'subscription.dart';
import 'user.dart';
import 'user_attributes.dart';

class GoTrueClient {
  /// Namespace for the GoTrue API methods.
  /// These can be used for example to get a user from a JWT in a server environment or reset a user's password.
  GoTrueApi api;

  /// The currently logged in user or null.
  User currentUser;

  /// The session object for the currently logged in user or null.
  Session currentSession;

  bool autoRefreshToken;
  bool persistSession;
  Storage localStorage;
  Map<String, Subscription> stateChangeEmitters;

  Timer _refreshTokenTimer;

  GoTrueClient(
      {String url,
      Map<String, String> headers,
      bool autoRefreshToken,
      bool persistSession,
      Storage localStorage,
      CookieOptions cookieOptions}) {
    this.autoRefreshToken = autoRefreshToken ?? true;
    this.persistSession = persistSession ?? true;

    final _url = url ?? Constants.defaultGotrueUrl;
    final _header = headers ?? Constants.defaultHeaders;
    api = GoTrueApi(_url, headers: _header, cookieOptions: cookieOptions);

    // TODO: localStorage and detectSessionInUrl
  }

  /// Returns the user data, if there is a logged in user.
  User user() {
    return currentUser;
  }

  /// Returns the session data, if there is an active session.
  Session session() {
    return currentSession;
  }

  /// Creates a new user.
  Future<GotrueSessionResponse> signUp(String email, String password) async {
    _removeSession();

    final response = await api.signUpWithEmail(email, password);
    if (response.error != null) return response;

    if (response.data?.user?.confirmedAt != null) {
      _saveSession(response.data);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  /// Log in an existing user, or login via a third-party provider.
  Future<GotrueSessionResponse> signIn(
      {String email, String password, Provider provider}) async {
    _removeSession();

    if (email != null) {
      if (password == null) {
        final response = await api.sendMagicLinkEmail(email);
        return GotrueSessionResponse(error: response.error);
      } else {
        return _handleEmailSignIn(email, password);
      }
    } else if (provider != null) {
      return _handleProviderSignIn(provider);
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

  /// Updates user data, if there is a logged in user.
  Future<GotrueUserResponse> update(UserAttributes attributes) async {
    if (currentSession?.accessToken == null) {
      final error = GotrueError('Not logged in.');
      return GotrueUserResponse(error: error);
    }

    final response =
        await api.updateUser(currentSession?.accessToken, attributes);
    if (response.error != null) return response;

    currentUser = response.user;
    _notifyAllSubscribers(AuthChangeEvent.userUpdated);

    return response;
  }

  /// Signs out the current user, if there is a logged in user.
  Future<GotrueResponse> signOut() async {
    if (currentSession != null) {
      final response = await api.signOut(currentSession.accessToken);
      if (response.error != null) return response;
    }

    _removeSession();
    _notifyAllSubscribers(AuthChangeEvent.signedOut);

    return GotrueResponse();
  }

  Future<GotrueSessionResponse> _handleEmailSignIn(
      String email, String password) async {
    final response = await api.signInWithEmail(email, password);
    if (response.error != null) return response;

    if (response.data?.user?.confirmedAt != null) {
      _saveSession(response.data);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  /// return provider url only
  GotrueSessionResponse _handleProviderSignIn(Provider provider) {
    final url = api.getUrlForProvider(provider);
    return GotrueSessionResponse(provider: provider.name(), url: url);
  }

  // TODO: not implemented yet
  void _removeSession() {}

  void _saveSession(Session session) {
    currentSession = session;
    currentUser = session.user;
    final tokenExpirySeconds = session.expiresIn;

    if (autoRefreshToken && tokenExpirySeconds != null) {
      if (_refreshTokenTimer != null) _refreshTokenTimer.cancel();

      final timerDuration = Duration(seconds: tokenExpirySeconds - 60);
      _refreshTokenTimer = Timer(timerDuration, () {
        _callRefreshToken();
      });
    }

    if (persistSession && currentUser != null) {
      _persistSession(currentSession, tokenExpirySeconds);
    }
  }

  // TODO: not implemented yet
  void _persistSession(Session currentSession, int secondsToExpiry) {}

  // TODO: not implemented yet
  void _recoverSession() {}

  Future<GotrueSessionResponse> _callRefreshToken({String refreshToken}) async {
    final token = refreshToken ?? currentSession?.refreshToken;
    if (token == null) {
      final error = GotrueError('No current session.');
      return GotrueSessionResponse(error: error);
    }

    final response = await api.refreshAccessToken(token);
    if (response.error != null) return response;

    if (response.data?.accessToken != null) {
      _saveSession(response.data);
      _notifyAllSubscribers(AuthChangeEvent.signedIn);
    }

    return response;
  }

  void _notifyAllSubscribers(AuthChangeEvent event) {
    stateChangeEmitters.forEach((k, v) => v.callback(event, currentSession));
  }
}
