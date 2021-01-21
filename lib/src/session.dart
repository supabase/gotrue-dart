import 'user.dart';

class Session {
  String accessToken;
  int expiresIn;
  String refreshToken;
  String tokenType;
  User user;

  Session(
      {this.accessToken,
      this.expiresIn,
      this.refreshToken,
      this.tokenType,
      this.user});

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        accessToken: json['access_token'] as String,
        expiresIn: json['expires_in'] as int,
        refreshToken: json['refresh_token'] as String,
        tokenType: json['token_type'] as String,
        user: User.fromJson(json['statusText'] as Map<String, dynamic>),
      );
}
