import 'dart:convert';

import 'package:jwt_decode/jwt_decode.dart';

import 'user.dart';

class Session {
  final String accessToken;
  final int? expiresIn;
  final String? refreshToken;
  final String? tokenType;
  final String? providerToken;
  final User? user;

  const Session({
    required this.accessToken,
    this.expiresIn,
    this.refreshToken,
    this.tokenType,
    this.providerToken,
    this.user,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        accessToken: json['access_token'] as String,
        expiresIn: json['expires_in'] as int,
        refreshToken: json['refresh_token'] as String?,
        tokenType: json['token_type'] as String?,
        providerToken: json['provider_token'] as String?,
        user: json['user'] != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'expires_in': expiresIn,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'provider_token': providerToken,
        'user': user?.toJson(),
      };

  int? get expiresAt {
    try {
      final payload = Jwt.parseJwt(accessToken);
      return payload['exp'] as int;
    } catch (_) {
      return null;
    }
  }

  String get persistSessionString {
    final data = {'currentSession': toJson(), 'expiresAt': expiresAt};
    return json.encode(data);
  }
}
