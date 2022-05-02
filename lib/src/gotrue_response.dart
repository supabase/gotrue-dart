import 'package:gotrue/src/gotrue_error.dart';
import 'package:gotrue/src/session.dart';
import 'package:gotrue/src/subscription.dart';
import 'package:gotrue/src/user.dart';

class GotrueResponse {
  final GotrueError? error;
  final dynamic rawData;
  final int? statusCode;

  const GotrueResponse({this.rawData, this.error, this.statusCode});
}

class GotrueJsonResponse extends GotrueResponse {
  final Map<String, dynamic>? data;

  const GotrueJsonResponse({
    this.data,
    GotrueError? error,
    int? statusCode,
  }) : super(
          error: error,
          statusCode: statusCode,
        );

  GotrueJsonResponse.fromResponse({required GotrueResponse response, this.data})
      : super(
          error: response.error,
          statusCode: response.statusCode,
          rawData: response.rawData,
        );
}

class GotrueSessionResponse extends GotrueResponse {
  final Session? data;
  final String? provider;
  final String? url;
  final User? user;

  GotrueSessionResponse({
    this.data,
    this.provider,
    this.url,
    User? user,
    GotrueError? error,
    int? statusCode,
  })  : user = user ?? data?.user,
        super(
          error: error,
          statusCode: statusCode,
        );

  GotrueSessionResponse.fromResponse({
    required GotrueResponse response,
    this.data,
    this.provider,
    this.url,
    User? user,
  })  : user = user ?? data?.user,
        super(
          error: response.error,
          statusCode: response.statusCode,
        );
}

class GotrueUserResponse extends GotrueResponse {
  final User? user;

  User? get data {
    return user;
  }

  const GotrueUserResponse({
    this.user,
    GotrueError? error,
    int? statusCode,
  }) : super(
          error: error,
          statusCode: statusCode,
        );

  GotrueUserResponse.fromResponse({required GotrueResponse response, this.user})
      : super(
          error: response.error,
          statusCode: response.statusCode,
        );
}

class GotrueSubscription extends GotrueResponse {
  final Subscription? data;

  const GotrueSubscription({this.data, GotrueError? error})
      : super(error: error);
}
