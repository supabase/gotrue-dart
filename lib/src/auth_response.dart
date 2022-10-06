import 'package:gotrue/src/provider.dart';
import 'package:gotrue/src/session.dart';
import 'package:gotrue/src/user.dart';

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

// class GotrueResponse {
//   final dynamic rawData;

//   const GotrueResponse({this.rawData});
// }

// class GotrueJsonResponse extends GotrueResponse {
//   final Map<String, dynamic>? data;

//   const GotrueJsonResponse({
//     this.data,
//     int? statusCode,
//   }) : super();

//   GotrueJsonResponse.fromResponse({required GotrueResponse response, this.data})
//       : super(
//           rawData: response.rawData,
//         );
// }

// class GotrueSessionResponse extends GotrueResponse {
//   final Session? session;
//   final String? provider;
//   final String? url;
//   final User? user;

//   GotrueSessionResponse({
//     this.session,
//     this.provider,
//     this.url,
//     User? user,
//     int? statusCode,
//   })  : user = user ?? session?.user,
//         super();

//   GotrueSessionResponse.fromResponse({
//     required GotrueResponse response,
//     this.session,
//     this.provider,
//     this.url,
//     User? user,
//   })  : user = user ?? session?.user,
//         super(
//           rawData: response.rawData,
//         );
// }

// class GotrueUserResponse extends GotrueResponse {
//   final User? user;

//   User? get data {
//     return user;
//   }

//   const GotrueUserResponse({
//     this.user,
//     int? statusCode,
//   }) : super();

//   GotrueUserResponse.fromResponse({required GotrueResponse response, this.user})
//       : super(
//           rawData: response.rawData,
//         );
// }

