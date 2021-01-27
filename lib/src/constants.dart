class Constants {
  static const String defaultGotrueUrl = 'http://localhost:9999';
  static const String defaultAudience = '';
  static const Map<String, String> defaultHeaders = {};
  static const int defaultExpiryMargin = 60 * 1000;
  static const String defaultStorageKey = 'supabase.auth.token';
}

class Provider {
  static const String bitbucket = 'bitbucket';
  static const String github = 'github';
  static const String gitlab = 'gitlab';
  static const String google = 'google';
}

class AuthChangeEvent {
  static const String signedIn = 'SIGNED_IN';
  static const String signedOut = 'SIGNED_OUT';
  static const String userUpdated = 'USER_UPDATED';
  static const String passwordRecovery = 'PASSWORD_RECOVERY';
}
