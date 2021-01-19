import 'cookie_options.dart';

class Constants {
  static const String defaultGotrueUrl = 'http://localhost:9999';
  static const String defaultAudience = '';
  static const Map<String, String> defaultHeaders = {};
  static const int defaultExpiryMargin = 60 * 1000;
  static const String defaultStorageKey = 'supabase.auth.token';
  static const CookieOptions defaultCookieOptions =
      CookieOptions('sb:token', 60 * 60 * 8, '', '/', 'lax');
}
