import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/fetch.dart';
import 'package:gotrue/src/fetch_options.dart';
import 'package:gotrue/src/open_id_connect_credentials.dart';

class GoTrueApi {
  String url;
  Map<String, String> headers;
  CookieOptions? cookieOptions;

  GoTrueApi(this.url, {Map<String, String>? headers, this.cookieOptions})
      : headers = headers ?? {};

  /// Creates a new user using their email address.
  ///
  /// [userMetadata] sets [User.userMetadata] without an extra call to [updateUser]
  Future<GotrueSessionResponse> signUpWithEmail(
    String email,
    String password, {
    AuthOptions? options,
    Map<String, dynamic>? userMetadata,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
        'data': userMetadata,
      };
      final fetchOptions = FetchOptions(headers);
      final urlParams = [];
      if (options?.redirectTo != null) {
        final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
        urlParams.add('redirect_to=$encodedRedirectTo');
      }
      final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
      final response = await fetch.post(
        '$url/signup$queryString',
        body,
        options: fetchOptions,
      );
      final data = response.rawData as Map<String, dynamic>;
      if (response.error != null) {
        return GotrueSessionResponse(error: response.error);
      } else if (data['access_token'] == null) {
        // email validation required
        User? user;
        if (data['id'] != null) {
          user = User.fromJson(data);
        }
        return GotrueSessionResponse(user: user);
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
    String email,
    String password, {
    AuthOptions? options,
  }) async {
    try {
      final body = {'email': email, 'password': password};
      final fetchOptions = FetchOptions(headers);
      final urlParams = ['grant_type=password'];
      if (options?.redirectTo != null) {
        final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
        urlParams.add('redirect_to=$encodedRedirectTo');
      }
      final queryString = '?${urlParams.join('&')}';
      final response = await fetch.post(
        '$url/token$queryString',
        body,
        options: fetchOptions,
      );
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

  /// Signs up a new user using their phone number and a password.
  ///
  /// [phone] is the user's phone number WITH international prefix
  ///
  /// [password] is the password of the user
  ///
  /// [userMetadata] sets [User.userMetadata] without an extra call to [updateUser]
  Future<GotrueSessionResponse> signUpWithPhone(
    String phone,
    String password, {
    Map<String, dynamic>? userMetadata,
  }) async {
    try {
      final fetchOptions = FetchOptions(headers);
      final body = {
        'phone': phone,
        'password': password,
        'data': userMetadata,
      };
      final response =
          await fetch.post('$url/signup', body, options: fetchOptions);
      final data = response.rawData as Map<String, dynamic>;
      if (response.error != null) {
        return GotrueSessionResponse(error: response.error);
      } else if ((response.rawData as Map<String, dynamic>)['access_token'] ==
          null) {
        // email validation required
        User? user;
        if (data['id'] != null) {
          user = User.fromJson(data);
        }
        return GotrueSessionResponse(user: user);
      } else {
        final session =
            Session.fromJson(response.rawData as Map<String, dynamic>);
        return GotrueSessionResponse(data: session);
      }
    } catch (e) {
      return GotrueSessionResponse(error: GotrueError(e.toString()));
    }
  }

  /// Logs in an existing user using their phone number and password.
  ///
  /// [phone] is the user's phone number WITH international prefix
  ///
  /// [password] is the password of the user
  Future<GotrueSessionResponse> signInWithPhone(
    String phone, [
    String? password,
  ]) async {
    try {
      final body = {'phone': phone, 'password': password};
      final fetchOptions = FetchOptions(headers);
      const queryString = '?grant_type=password';
      final response = await fetch.post(
        '$url/token$queryString',
        body,
        options: fetchOptions,
      );
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

  /// Logs in an OpenID Connect user using their idToken.
  Future<GotrueSessionResponse> signInWithOpenIDConnect(
    OpenIDConnectCredentials oidc,
  ) async {
    try {
      final body = {
        'id_token': oidc.idToken,
        'nonce': oidc.nonce,
        'client_id': oidc.clientId,
        "issuer": oidc.issuer,
        'provider': oidc.provider?.name(),
      };
      final fetchOptions = FetchOptions(headers);
      const queryString = '?grant_type=id_token';
      final response = await fetch.post(
        '$url/token$queryString',
        body,
        options: fetchOptions,
      );
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
  Future<GotrueJsonResponse> sendMagicLinkEmail(
    String email, {
    AuthOptions? options,
  }) async {
    try {
      final body = {'email': email};
      final fetchOptions = FetchOptions(headers);
      final urlParams = [];
      if (options?.redirectTo != null) {
        final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
        urlParams.add('redirect_to=$encodedRedirectTo');
      }
      final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
      final response = await fetch.post(
        '$url/magiclink$queryString',
        body,
        options: fetchOptions,
      );
      if (response.error != null) {
        return GotrueJsonResponse(error: response.error);
      } else {
        return GotrueJsonResponse(
          data: response.rawData as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return GotrueJsonResponse(error: GotrueError(e.toString()));
    }
  }

  /// Sends a mobile OTP via SMS. Will register the account if it doesn't already exist
  ///
  /// [phone] is the user's phone number WITH international prefix
  Future<GotrueJsonResponse> sendMobileOTP(String phone) async {
    try {
      final body = {'phone': phone};
      final fetchOptions = FetchOptions(headers);
      final response =
          await fetch.post('$url/otp', body, options: fetchOptions);
      if (response.error != null) {
        return GotrueJsonResponse(error: response.error);
      } else {
        return GotrueJsonResponse(
          data: response.rawData as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return GotrueJsonResponse(error: GotrueError(e.toString()));
    }
  }

  /// Send User supplied Mobile OTP to be verified
  ///
  /// [phone] is the user's phone number WITH international prefix
  ///
  /// [token] is the token that user was sent to their mobile phone
  Future<GotrueSessionResponse> verifyMobileOTP(
    String phone,
    String token, {
    AuthOptions? options,
  }) async {
    try {
      final body = {
        'phone': phone,
        'token': token,
        'type': 'sms',
        'redirect_to': options?.redirectTo,
      };
      final fetchOptions = FetchOptions(headers);
      final response =
          await fetch.post('$url/verify', body, options: fetchOptions);
      if (response.error != null) {
        return GotrueSessionResponse(error: response.error);
      } else {
        Session session =
            Session.fromJson(response.rawData as Map<String, dynamic>);
        // if the user in the current session is null, we get the user based on
        // the session's jwt token
        if (session.user == null) {
          final userResponse = await getUser(session.accessToken);
          if (userResponse.user != null) {
            session = session.copyWith(user: userResponse.user);
          }
        }
        return GotrueSessionResponse(data: session);
      }
    } catch (e) {
      return GotrueSessionResponse(error: GotrueError(e.toString()));
    }
  }

  /// Sends an invite link to an email address.
  Future<GotrueJsonResponse> inviteUserByEmail(
    String email, {
    AuthOptions? options,
  }) async {
    try {
      final body = {'email': email};
      final fetchOptions = FetchOptions(headers);
      final urlParams = [];
      if (options?.redirectTo != null) {
        final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
        urlParams.add('redirect_to=$encodedRedirectTo');
      }
      final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
      final response = await fetch.post(
        '$url/invite$queryString',
        body,
        options: fetchOptions,
      );
      if (response.error != null) {
        return GotrueJsonResponse(error: response.error);
      } else {
        return GotrueJsonResponse(
          data: response.rawData as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return GotrueJsonResponse(error: GotrueError(e.toString()));
    }
  }

  /// Sends a reset request to an email address.
  Future<GotrueJsonResponse> resetPasswordForEmail(
    String email, {
    AuthOptions? options,
  }) async {
    try {
      final body = {'email': email};
      final fetchOptions = FetchOptions(headers);
      final urlParams = [];
      if (options?.redirectTo != null) {
        final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
        urlParams.add('redirect_to=$encodedRedirectTo');
      }
      final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
      final response = await fetch.post(
        '$url/recover$queryString',
        body,
        options: fetchOptions,
      );
      if (response.error != null) {
        return GotrueJsonResponse(error: response.error);
      } else {
        return GotrueJsonResponse(
          data: response.rawData as Map<String, dynamic>?,
        );
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

  String getUrlForProvider(Provider provider, AuthOptions? options) {
    final urlParams = ['provider=${provider.name()}'];
    if (options?.scopes != null) {
      urlParams.add('scopes=${options!.scopes!}');
    }
    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams.add('redirect_to=$encodedRedirectTo');
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
    String jwt,
    UserAttributes attributes,
  ) async {
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
  Future<GotrueSessionResponse> refreshAccessToken(
    String refreshToken, [
    String? jwt,
  ]) async {
    try {
      final body = {'refresh_token': refreshToken};
      if (jwt != null) {
        headers['Authorization'] = 'Bearer $jwt';
      }
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
  Never setAuthCookie() {
    throw UnimplementedError();
  }

  // TODO: not implemented yet
  Never getUserByCookie() {
    throw UnimplementedError();
  }
}
