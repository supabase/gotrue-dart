import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/fetch.dart';
import 'package:gotrue/src/fetch_options.dart';
import 'package:http/http.dart';

class GoTrueApi {
  final String url;
  final Map<String, String> headers;
  final CookieOptions? cookieOptions;
  final Client? _httpClient;
  late final GotrueFetch _fetch = GotrueFetch(_httpClient);

  GoTrueApi(
    this.url, {
    Map<String, String>? headers,
    this.cookieOptions,
    Client? httpClient,
  })  : headers = headers ?? {},
        _httpClient = httpClient;

  /// Creates a new user using their email address.
  ///
  /// [userMetadata] sets [User.userMetadata] without an extra call to [updateUser]
  Future<GotrueSessionResponse> signUpWithEmail(
    String email,
    String password, {
    AuthOptions? options,
    Map<String, dynamic>? userMetadata,
  }) async {
    final urlParams = [];

    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams.add('redirect_to=$encodedRedirectTo');
    }

    final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
    final response = await _fetch.post(
      '$url/signup$queryString',
      {
        'email': email,
        'password': password,
        'data': userMetadata,
        'gotrue_meta_security': {'hcaptcha_token': options?.captchaToken},
      },
      options: FetchOptions(headers),
    );
    final data = response.rawData as Map<String, dynamic>?;
    if (data != null && data['access_token'] == null) {
      // email validation required
      User? user;
      if (data['id'] != null) {
        user = User.fromJson(data);
      }
      return GotrueSessionResponse.fromResponse(
        response: response,
        user: user,
      );
    } else {
      final session =
          Session.fromJson(response.rawData as Map<String, dynamic>);
      return GotrueSessionResponse.fromResponse(
        response: response,
        session: session,
      );
    }
  }

  /// Logs in an existing user using their email address.
  Future<GotrueSessionResponse> signInWithEmail(
    String email,
    String password, {
    AuthOptions? options,
  }) async {
    final urlParams = ['grant_type=password'];
    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams.add('redirect_to=$encodedRedirectTo');
    }
    final queryString = '?${urlParams.join('&')}';
    final response = await _fetch.post(
      '$url/token$queryString',
      {'email': email, 'password': password},
      options: FetchOptions(headers),
    );
    final session = Session.fromJson(response.rawData as Map<String, dynamic>);
    return GotrueSessionResponse.fromResponse(
      response: response,
      session: session,
    );
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
    AuthOptions? options,
    Map<String, dynamic>? userMetadata,
  }) async {
    final fetchOptions = FetchOptions(headers);
    final body = {
      'phone': phone,
      'password': password,
      'data': userMetadata,
      'gotrue_meta_security': {'hcaptcha_token': options?.captchaToken},
    };
    final response =
        await _fetch.post('$url/signup', body, options: fetchOptions);
    final data = response.rawData as Map<String, dynamic>?;
    if (data != null && data['access_token'] == null) {
      // email validation required
      User? user;
      if (data['id'] != null) {
        user = User.fromJson(data);
      }
      return GotrueSessionResponse.fromResponse(
        response: response,
        user: user,
      );
    } else {
      final session = Session.fromJson(
        response.rawData as Map<String, dynamic>,
      );
      return GotrueSessionResponse.fromResponse(
        response: response,
        session: session,
      );
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
    const queryString = '?grant_type=password';
    final response = await _fetch.post(
      '$url/token$queryString',
      {'phone': phone, 'password': password},
      options: FetchOptions(headers),
    );
    final session = Session.fromJson(response.rawData as Map<String, dynamic>);
    return GotrueSessionResponse.fromResponse(
      response: response,
      session: session,
    );
  }

  /// Logs in an OpenID Connect user using their idToken.
  Future<GotrueSessionResponse> signInWithOpenIDConnect(
    OpenIDConnectCredentials oidc,
  ) async {
    final body = {
      'id_token': oidc.idToken,
      'nonce': oidc.nonce,
      'client_id': oidc.clientId,
      'issuer': oidc.issuer,
      'provider': oidc.provider?.name(),
    };
    final fetchOptions = FetchOptions(headers);
    const queryString = '?grant_type=id_token';
    final response = await _fetch.post(
      '$url/token$queryString',
      body,
      options: fetchOptions,
    );
    final session = Session.fromJson(response.rawData as Map<String, dynamic>);
    return GotrueSessionResponse.fromResponse(
      response: response,
      session: session,
    );
  }

  /// Sends a magic login link to an email address.
  Future<GotrueJsonResponse> sendMagicLinkEmail(
    String email, {
    AuthOptions? options,
    bool? shouldCreateUser,
  }) async {
    final fetchOptions = FetchOptions(headers);
    final urlParams = [];
    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams.add('redirect_to=$encodedRedirectTo');
    }
    final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
    final response = await _fetch.post(
      '$url/otp$queryString',
      {
        'email': email,
        'create_user': shouldCreateUser,
        'gotrue_meta_security': {'hcaptcha_token': options?.captchaToken},
      },
      options: fetchOptions,
    );
    return GotrueJsonResponse.fromResponse(
      response: response,
      data: response.rawData as Map<String, dynamic>?,
    );
  }

  /// Sends a mobile OTP via SMS. Will register the account if it doesn't already exist
  ///
  /// [phone] is the user's phone number WITH international prefix
  Future<GotrueJsonResponse> sendMobileOTP(
    String phone, {
    AuthOptions? options,
    bool? shouldCreateUser,
  }) async {
    final body = {
      'phone': phone,
      'create_user': shouldCreateUser,
      'gotrue_meta_security': {'hcaptcha_token': options?.captchaToken},
    };
    final fetchOptions = FetchOptions(headers);
    final response = await _fetch.post('$url/otp', body, options: fetchOptions);
    return GotrueJsonResponse.fromResponse(
      response: response,
      data: response.rawData as Map<String, dynamic>?,
    );
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
    final body = {
      'phone': phone,
      'token': token,
      'type': 'sms',
      'redirect_to': options?.redirectTo,
    };
    final fetchOptions = FetchOptions(headers);
    final response =
        await _fetch.post('$url/verify', body, options: fetchOptions);
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
    return GotrueSessionResponse.fromResponse(
      response: response,
      session: session,
    );
  }

  /// Sends an invite link to an email address.
  Future<GotrueJsonResponse> inviteUserByEmail(
    String email, {
    AuthOptions? options,
  }) async {
    final body = {'email': email};
    final fetchOptions = FetchOptions(headers);
    final urlParams = [];
    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams.add('redirect_to=$encodedRedirectTo');
    }
    final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
    final response = await _fetch.post(
      '$url/invite$queryString',
      body,
      options: fetchOptions,
    );
    return GotrueJsonResponse.fromResponse(
      response: response,
      data: response.rawData as Map<String, dynamic>?,
    );
  }

  /// Generates links to be sent via email or other.
  Future<GotrueJsonResponse> generateLink(
    String email,
    InviteType type, {
    AuthOptions? options,
    String? password,
    Map<String, dynamic>? userMetadata,
  }) async {
    final body = {
      'email': email,
      'type': type.name,
      'data': userMetadata,
      'redirect_to': options?.redirectTo,
      'password': password,
    };

    final fetchOptions = FetchOptions(headers);

    final response = await _fetch.post(
      '$url/admin/generate_link',
      body,
      options: fetchOptions,
    );
    return GotrueJsonResponse.fromResponse(
      response: response,
      data: response.rawData as Map<String, dynamic>?,
    );
  }

  /// Sends a reset request to an email address.
  Future<GotrueJsonResponse> resetPasswordForEmail(
    String email, {
    AuthOptions? options,
  }) async {
    final body = {
      'email': email,
      'gotrue_meta_security': {'hcaptcha_token': options?.captchaToken},
    };
    final fetchOptions = FetchOptions(headers);
    final urlParams = [];
    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams.add('redirect_to=$encodedRedirectTo');
    }
    final queryString = urlParams.isNotEmpty ? '?${urlParams.join('&')}' : '';
    final response = await _fetch.post(
      '$url/recover$queryString',
      body,
      options: fetchOptions,
    );
    return GotrueJsonResponse.fromResponse(
      response: response,
      data: response.rawData as Map<String, dynamic>?,
    );
  }

  /// Removes a logged-in session.
  Future<GotrueResponse> signOut(String jwt) async {
    final headers = {...this.headers};
    headers['Authorization'] = 'Bearer $jwt';
    final options = FetchOptions(headers, noResolveJson: true);
    final response = await _fetch.post('$url/logout', {}, options: options);
    return response;
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
    final headers = {...this.headers};
    headers['Authorization'] = 'Bearer $jwt';
    final options = FetchOptions(headers);
    final response = await _fetch.get('$url/user', options: options);
    final user = User.fromJson(response.rawData as Map<String, dynamic>);
    return GotrueUserResponse.fromResponse(response: response, user: user);
  }

  /// Updates the user data.
  Future<GotrueUserResponse> updateUser(
    String jwt,
    UserAttributes attributes,
  ) async {
    final body = attributes.toJson();
    final headers = {...this.headers};
    headers['Authorization'] = 'Bearer $jwt';
    final options = FetchOptions(headers);
    final response = await _fetch.put('$url/user', body, options: options);
    final user = User.fromJson(response.rawData as Map<String, dynamic>);
    return GotrueUserResponse.fromResponse(response: response, user: user);
  }

  /// Generates a new JWT.
  Future<GotrueSessionResponse> refreshAccessToken(
    String refreshToken, [
    String? jwt,
  ]) async {
    final body = {'refresh_token': refreshToken};
    if (jwt != null) {
      headers['Authorization'] = 'Bearer $jwt';
    }
    final options = FetchOptions(headers);
    final response = await _fetch
        .post('$url/token?grant_type=refresh_token', body, options: options);
    final session = Session.fromJson(response.rawData as Map<String, dynamic>);
    return GotrueSessionResponse.fromResponse(
      response: response,
      session: session,
    );
  }
}
