import 'package:gotrue/src/version.dart';

class Constants {
  static const String defaultGotrueUrl = 'http://localhost:9999';
  static const String defaultAudience = '';
  static const Map<String, String> defaultHeaders = {
    'X-Client-Info': 'gotrue-dart/$version',
  };
  static const int defaultExpiryMargin = 60 * 1000;
  static const String defaultStorageKey = 'supabase.auth.token';
}

enum AuthChangeEvent { signedIn, signedOut, userUpdated, passwordRecovery }

extension AuthChangeEventName on AuthChangeEvent {
  String name() {
    return toString().split('.').last;
  }
}
