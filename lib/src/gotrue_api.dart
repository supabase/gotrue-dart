import 'utils/constants.dart';
import 'utils/cookie_options.dart';

class GoTrueApi {
  GoTrueApi(this.url,
      {this.headers = const {},
      this.cookieOptions = Constants.defaultCookieOptions});

  String url;
  Map<String, String> headers;
  CookieOptions cookieOptions;
}
