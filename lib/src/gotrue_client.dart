import 'constants.dart';
import 'cookie_options.dart';
import 'gotrue_api.dart';
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
}
