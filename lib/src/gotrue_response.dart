import 'gotrue_error.dart';
import 'session.dart';
import 'subscription.dart';
import 'user.dart';

class GotrueResponse {
  final GotrueError? error;
  final dynamic rawData;

  const GotrueResponse({this.rawData, this.error});
}

class GotrueJsonResponse extends GotrueResponse {
  final Map<String, dynamic>? data;

  const GotrueJsonResponse({this.data, GotrueError? error})
      : super(error: error);
}

class GotrueSessionResponse extends GotrueResponse {
  final Session? data;

  final String? provider;
  final String? url;

  User? get user {
    return data?.user;
  }

  const GotrueSessionResponse({
    this.data,
    this.provider,
    this.url,
    GotrueError? error,
  }) : super(error: error);
}

class GotrueUserResponse extends GotrueResponse {
  final User? user;

  User? get data {
    return user;
  }

  const GotrueUserResponse({
    this.user,
    GotrueError? error,
  }) : super(error: error);
}

class GotrueSubscription extends GotrueResponse {
  final Subscription? data;

  const GotrueSubscription({
    this.data,
    GotrueError? error,
  }) : super(error: error);
}
