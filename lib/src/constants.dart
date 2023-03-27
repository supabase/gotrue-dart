import 'package:gotrue/src/types/auth_response.dart';
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
  mfaChallengeVerified,
  tokenRefreshFailed,
}

enum GenerateLinkType {
  signup,
  invite,
  magiclink,
  recovery,
  emailChangeCurrent,
  emailChangeNew,
}

extension GenerateLinkTypeExtended on GenerateLinkType {
  static GenerateLinkType fromString(String val) {
    for (final type in GenerateLinkType.values) {
      if (type.snakeCase == val) {
        return type;
      }
    }
    throw Exception('GenerateLinkType of $val was not found');
  }
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

extension EnumName on Enum {
  String get name {
    return toString().split('.').last;
  }
}
