class Constants {
  static const String defaultGotrueUrl = 'http://localhost:9999';
  static const String defaultAudience = '';
  static const Map<String, String> defaultHeaders = {};
  static const int defaultExpiryMargin = 60 * 1000;
  static const String defaultStorageKey = 'supabase.auth.token';
}

enum Provider { bitbucket, github, gitlab, google }

extension ProviderName on Provider {
  String name() {
    return toString().split('.').last;
  }
}

enum AuthChangeEvent { signedIn, signedOut, userUpdated, passwordRecovery }

extension AuthChangeEventName on AuthChangeEvent {
  String name() {
    return toString().split('.').last;
  }
}
