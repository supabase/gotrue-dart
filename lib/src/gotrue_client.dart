import 'constants.dart';
import 'cookie_options.dart';
import 'gotrue_api.dart';
import 'gotrue_response.dart';
import 'session.dart';
import 'storage.dart';
import 'subscription.dart';
import 'user.dart';

class GoTrueClient {
  /// Namespace for the GoTrue API methods.
  /// These can be used for example to get a user from a JWT in a server environment or reset a user's password.
  GoTrueApi api;

  ///The currently logged in user or null.
  User currentUser;

  ///The session object for the currently logged in user or null.
  Session currentSession;

  bool autoRefreshToken;
  bool persistSession;
  Storage localStorage;
  Map<String, Subscription> stateChangeEmitters;

  GoTrueClient(
      {String url,
      Map<String, String> headers,
      bool detectSessionInUrl,
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

  Future<GotrueSessionResponse> signUp(String email, String password) async {
    final response = await api.signInWithEmail(email, password);
    if (response.error != null) return response;

    if (response.data?.user?.confirmedAt != null) {
      _saveSession(response.data);
      _notifyAllSubscribers(AuthChangeEvent.signedOut);
    }

    return response;
  }

  // TODO: not implemented yet
  void _handleEmailSignIn(String email, String password) {}

  // TODO: not implemented yet
  void _handleProviderSignIn(Provider provider) {}

  // TODO: not implemented yet
  void _removeSession() {}

  void _saveSession(Session session) {
    currentSession = session;
    currentUser = session.user;
    final tokenExpirySeconds = session.expiresIn;

    if (autoRefreshToken && tokenExpirySeconds != null) {
      // TODO: call to _callRefreshToken
    }

    if (persistSession) {
      _persistSession(currentSession, tokenExpirySeconds);
    }
  }

  // TODO: not implemented yet
  void _persistSession(Session currentSession, int secondsToExpiry) {}

  // TODO: not implemented yet
  void _recoverSession() {}

  // TODO: not implemented yet
  void _callRefreshToken(String refreshToken) {}

  void _notifyAllSubscribers(AuthChangeEvent event) {
    stateChangeEmitters.forEach((k, v) => v.callback(event, currentSession));
  }
}
