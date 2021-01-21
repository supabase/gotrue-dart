import 'constants.dart';
import 'cookie_options.dart';
import 'gotrue_response.dart';

class GoTrueApi {
  String url;
  Map<String, String> headers;
  CookieOptions cookieOptions;

  GoTrueApi(this.url,
      {this.headers = const {},
      this.cookieOptions = Constants.defaultCookieOptions});

  Future<GotrueSessionResponse> signUpWithEmail(
      String email, String password) async {}
}
