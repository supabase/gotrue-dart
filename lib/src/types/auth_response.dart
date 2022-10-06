import 'package:gotrue/src/types/provider.dart';
import 'package:gotrue/src/types/session.dart';
import 'package:gotrue/src/types/subscription.dart';
import 'package:gotrue/src/types/user.dart';

/// Response which might or might not contain session and/or user
class AuthResponse {
  final Session? session;
  final User? user;

  AuthResponse({
    this.session,
    this.user,
  });

  /// Instanciates an `AuthResponse` object from json response.
  AuthResponse.fromJson(Map<String, dynamic> json)
      : session = Session.fromJson(json),
        user = User.fromJson(json) ?? Session.fromJson(json)?.user;
}

/// Response of OAuth signin
class OAuthResponse {
  final Provider provider;
  final String? url;

  /// Instanciates an `OAuthResponse` object from json response.
  OAuthResponse({
    required this.provider,
    this.url,
  });
}

/// Response that contains a user
class UserResponse {
  final User? user;

  UserResponse.fromJson(Map<String, dynamic> json) : user = User.fromJson(json);
}

class AuthSubscription {
  final Subscription? data;

  const AuthSubscription({this.data}) : super();
}

class GenerateLinkResponse {
  final GenerateLinkProperties properties;
  final User user;

  GenerateLinkResponse.fromJson(Map<String, dynamic> json)
      : properties = GenerateLinkProperties.fromJson(json),
        user = User.fromJson(json)!;
}

class GenerateLinkProperties {
  /// The email link to send to the user.
  /// The action_link follows the following format: auth/v1/verify?type={verification_type}&token={hashed_token}&redirect_to={redirect_to}
  final String actionLink;

  /// The raw email OTP.
  /// You should send this in the email if you want your users to verify using an OTP instead of the action link.
  final String emailOtp;

  /// The hashed token appended to the action link.
  final String hashedToken;

  /// The URL appended to the action link.
  final String redirectTo;

  /// The verification type that the email link is associated to.
  final GenerateLinkType verificationType;

  GenerateLinkProperties.fromJson(Map<String, dynamic> json)
      : actionLink = json['action_link'],
        emailOtp = json['email_otp'],
        hashedToken = json['hashed_token'],
        redirectTo = json['redirect_to'],
        verificationType =
            GenerateLinkType.fromString(json['verification_type']);
}

enum GenerateLinkType {
  signup,
  invite,
  magiclink,
  recovery,
  emailChangeCurrent,
  emailChangeNew;

  static GenerateLinkType fromString(String val) {
    for (final type in GenerateLinkType.values) {
      if (type.snakeCase == val) {
        return type;
      }
    }
    throw Exception('GenerateLinkType of $val was not found');
  }
}

extension ToSnakeCase on Enum {
  String get snakeCase {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return name
        .replaceAllMapped(exp, (Match m) => ('_${m.group(0)}'))
        .toLowerCase();
  }
}
