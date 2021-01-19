import 'gotrue_error.dart';
import 'utils/session.dart';
import 'utils/user.dart';

class GotrueResponse {
  GotrueError error;

  GotrueResponse({this.error});
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
