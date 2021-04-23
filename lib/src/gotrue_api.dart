import 'cookie_options.dart';
import 'fetch.dart';
import 'fetch_options.dart';
import 'gotrue_error.dart';
import 'gotrue_response.dart';
import 'provider.dart';
import 'session.dart';
import 'user.dart';
import 'user_attributes.dart';



class GoTrueApi {
  String url;
  Map<String, String> headers;
  CookieOptions? cookieOptions;

  GoTrueApi(this.url, {Map<String, String>? headers, this.cookieOptions})
      : headers = headers ?? {};

  /// Creates a new user using their email address.
  Future<GotrueSessionResponse> signUpWithEmail(
      String email, String password) async {
    try {
      final body = {'email': email, 'password': password};
      final options = FetchOptions(headers);
      final response = await fetch.post('$url/signup', body, options: options);
      if (response.error != null) {
        return GotrueSessionResponse(error: response.error);
      } else if ((response.rawData as Map<String, dynamic>)['access_token'] ==
          null) {
        // email validation required
        return GotrueSessionResponse();
      } else {
        final session =
            Session.fromJson(response.rawData as Map<String, dynamic>);
        return GotrueSessionResponse(data: session);
      }
    } catch (e) {
      return GotrueSessionResponse(error: GotrueError(e.toString()));
    }
  }

  /// Logs in an existing user using their email address.
  Future<GotrueSessionResponse> signInWithEmail(
      String email, String password) async {
    try {
      final body = {'email': email, 'password': password};
      final options = FetchOptions(headers);
      final response = await fetch.post('$url/token?grant_type=password', body,
          options: options);
      if (response.error != null) {
        return GotrueSessionResponse(error: response.error);
      } else {
        final session =
            Session.fromJson(response.rawData as Map<String, dynamic>);
        return GotrueSessionResponse(data: session);
      }
    } catch (e) {
      return GotrueSessionResponse(error: GotrueError(e.toString()));
    }
  }

  /// Sends a magic login link to an email address.
  Future<GotrueJsonResponse> sendMagicLinkEmail(String email) async {
    try {
      final body = {'email': email};
      final options = FetchOptions(headers);
      final response =
          await fetch.post('$url/magiclink', body, options: options);
      if (response.error != null) {
        return GotrueJsonResponse(error: response.error);
      } else {
        return GotrueJsonResponse(
            data: response.rawData as Map<String, dynamic>?);
      }
    } catch (e) {
      return GotrueJsonResponse(error: GotrueError(e.toString()));
    }
  }

  /// Sends an invite link to an email address.
  Future<GotrueJsonResponse> inviteUserByEmail(String email) async {
    try {
      final body = {'email': email};
      final options = FetchOptions(headers);
      final response = await fetch.post('$url/invite', body, options: options);
      if (response.error != null) {
        return GotrueJsonResponse(error: response.error);
      } else {
        return GotrueJsonResponse(
            data: response.rawData as Map<String, dynamic>?);
      }
    } catch (e) {
      return GotrueJsonResponse(error: GotrueError(e.toString()));
    }
  }

  /// Sends a reset request to an email address.
  Future<GotrueJsonResponse> resetPasswordForEmail(String email) async {
    try {
      final body = {'email': email};
      final options = FetchOptions(headers);
      final response = await fetch.post('$url/recover', body, options: options);
      if (response.error != null) {
        return GotrueJsonResponse(error: response.error);
      } else {
        return GotrueJsonResponse(
            data: response.rawData as Map<String, dynamic>?);
      }
    } catch (e) {
      return GotrueJsonResponse(error: GotrueError(e.toString()));
    }
  }

  /// Removes a logged-in session.
  Future<GotrueResponse> signOut(String jwt) async {
    try {
      final headers = {...this.headers};
      headers['Authorization'] = 'Bearer $jwt';
      final options = FetchOptions(headers, noResolveJson: true);
      final response = await fetch.post('$url/logout', {}, options: options);
      return response;
    } catch (e) {
      return GotrueResponse(error: GotrueError(e.toString()));
    }
  }

  String getUrlForProvider(Provider provider, ProviderOptions? options) {
    final urlParams = ['provider=${provider.name()}'];
    if (options?.scopes != null) {
      urlParams.add('scopes=${options!.scopes!}');
    }
    if (options?.redirectTo != null) {
      urlParams.add('redirect_to=${options!.redirectTo!}');
    }
    return '$url/authorize?${urlParams.join('&')}';
  }

  /// Gets the user details.
  Future<GotrueUserResponse> getUser(String jwt) async {
    try {
      final headers = {...this.headers};
      headers['Authorization'] = 'Bearer $jwt';
      final options = FetchOptions(headers);
      final response = await fetch.get('$url/user', options: options);
      if (response.error != null) {
        return GotrueUserResponse(error: response.error);
      } else {
        final user = User.fromJson(response.rawData as Map<String, dynamic>);
        return GotrueUserResponse(user: user);
      }
    } catch (e) {
      return GotrueUserResponse(error: GotrueError(e.toString()));
    }
  }

  /// Updates the user data.
  Future<GotrueUserResponse> updateUser(
      String jwt, UserAttributes attributes) async {
    try {
      final body = attributes.toJson();
      final headers = {...this.headers};
      headers['Authorization'] = 'Bearer $jwt';
      final options = FetchOptions(headers);
      final response = await fetch.put('$url/user', body, options: options);
      if (response.error != null) {
        return GotrueUserResponse(error: response.error);
      } else {
        final user = User.fromJson(response.rawData as Map<String, dynamic>);
        return GotrueUserResponse(user: user);
      }
    } catch (e) {
      return GotrueUserResponse(error: GotrueError(e.toString()));
    }
  }

  /// Generates a new JWT.
  Future<GotrueSessionResponse> refreshAccessToken(String refreshToken) async {
    try {
      final body = {'refresh_token': refreshToken};
      final options = FetchOptions(headers);
      final response = await fetch
          .post('$url/token?grant_type=refresh_token', body, options: options);
      if (response.error != null) {
        return GotrueSessionResponse(error: response.error);
      } else {
        final session =
            Session.fromJson(response.rawData as Map<String, dynamic>);
        return GotrueSessionResponse(data: session);
      }
    } catch (e) {
      return GotrueSessionResponse(error: GotrueError(e.toString()));
    }
  }

  // TODO: not implemented yet
  void setAuthCookie() {}

  // TODO: not implemented yet
  void getUserByCookie() {}
}
