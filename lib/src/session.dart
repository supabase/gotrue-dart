import 'dart:convert';

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
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'expires_in': expiresIn,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'user': user?.toJson(),
      };

  String get persistSessionString {
    final timeNow = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final expiresAt = timeNow + expiresIn;
    final data = {'currentSession': toJson(), 'expiresAt': expiresAt};
    return json.encode(data);
  }
}
