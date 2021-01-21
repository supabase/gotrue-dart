import 'gotrue_error.dart';
import 'session.dart';
import 'user.dart';

class GotrueResponse {
  GotrueError error;
  dynamic rawData;

  GotrueResponse({this.rawData, this.error});
}

class GotrueBaseResponse extends GotrueResponse {
  Map<String, dynamic> data;

  GotrueBaseResponse({this.data, GotrueError error}) : super(error: error);
}

class GotrueSessionResponse extends GotrueResponse {
  Session data;

  GotrueSessionResponse({this.data, GotrueError error}) : super(error: error);
}

class GotrueUserResponse extends GotrueResponse {
  User data;
  User user;

  GotrueUserResponse({this.user, GotrueError error})
      : data = user,
        super(error: error);
}
