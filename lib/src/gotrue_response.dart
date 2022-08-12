import 'package:gotrue/src/session.dart';
import 'package:gotrue/src/subscription.dart';
import 'package:gotrue/src/user.dart';

class GotrueResponse {
  final dynamic rawData;
  final int? statusCode;

  const GotrueResponse({this.rawData, this.statusCode});
}

class GotrueJsonResponse extends GotrueResponse {
  final Map<String, dynamic>? data;

  const GotrueJsonResponse({
    this.data,
    int? statusCode,
  }) : super(
          statusCode: statusCode,
        );

  GotrueJsonResponse.fromResponse({required GotrueResponse response, this.data})
      : super(
          statusCode: response.statusCode,
          rawData: response.rawData,
        );
}

class GotrueSessionResponse extends GotrueResponse {
  final Session? session;
  final String? provider;
  final String? url;
  final User? user;

  GotrueSessionResponse({
    this.session,
    this.provider,
    this.url,
    User? user,
    int? statusCode,
  })  : user = user ?? session?.user,
        super(
          statusCode: statusCode,
        );

  GotrueSessionResponse.fromResponse({
    required GotrueResponse response,
    this.session,
    this.provider,
    this.url,
    User? user,
  })  : user = user ?? session?.user,
        super(
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
    int? statusCode,
  }) : super(
          statusCode: statusCode,
        );

  GotrueUserResponse.fromResponse({required GotrueResponse response, this.user})
      : super(
          statusCode: response.statusCode,
        );
}

class GotrueSubscription extends GotrueResponse {
  final Subscription? data;

  const GotrueSubscription({this.data}) : super();
}
