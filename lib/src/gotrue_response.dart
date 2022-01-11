import 'package:gotrue/src/gotrue_error.dart';
import 'package:gotrue/src/session.dart';
import 'package:gotrue/src/subscription.dart';
import 'package:gotrue/src/user.dart';

class GotrueResponse {
  GotrueError? error;
  dynamic rawData;

  GotrueResponse({this.rawData, this.error});
}

class GotrueJsonResponse extends GotrueResponse {
  Map<String, dynamic>? data;

  GotrueJsonResponse({this.data, GotrueError? error}) : super(error: error);
}

class GotrueSessionResponse extends GotrueResponse {
  Session? data;

  String? provider;
  String? url;

  User? get user {
    return data?.user;
  }

  GotrueSessionResponse({
    this.data,
    this.provider,
    this.url,
    GotrueError? error,
  }) : super(error: error);
}

class GotrueUserResponse extends GotrueResponse {
  User? user;

  User? get data {
    return user;
  }

  GotrueUserResponse({this.user, GotrueError? error}) : super(error: error);
}

class GotrueSubscription extends GotrueResponse {
  Subscription? data;

  GotrueSubscription({this.data, GotrueError? error}) : super(error: error);
}
