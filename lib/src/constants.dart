import 'package:gotrue/src/version.dart';

class Constants {
  static const String defaultGotrueUrl = 'http://localhost:9999';
  static const String defaultAudience = '';
  static const Map<String, String> defaultHeaders = {
    'X-Client-Info': 'gotrue-dart/$version',
  };
  static const int defaultExpiryMargin = 60 * 1000;
  static const String defaultStorageKey = 'supabase.auth.token';
  static const expiryMargin = Duration(seconds: 10);
  static const int maxRetryCount = 10;
  static const retryInterval = Duration(milliseconds: 200);
}

enum AuthChangeEvent {
  passwordRecovery,
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
  userDeleted,
}

enum InviteType {
  signup,
  magiclink,
  recovery,
  invite,
}

enum OtpType {
  sms,
  phoneChange,
  signup,
  invite,
  magiclink,
  recovery,
  emailChange
}
