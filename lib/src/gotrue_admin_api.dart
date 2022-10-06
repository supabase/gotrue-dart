import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/fetch.dart';
import 'package:gotrue/src/types/fetch_options.dart';
import 'package:http/http.dart';

class GoTrueAdminApi {
  final String url;
  final Map<String, String> headers;

  final Client? _httpClient;
  late final GotrueFetch _fetch = GotrueFetch(_httpClient);

  GoTrueAdminApi(
    this.url, {
    Map<String, String>? headers,
    Client? httpClient,
  })  : headers = headers ?? {},
        _httpClient = httpClient;

  /// Logs in an OpenID Connect user using their idToken.
  Future<AuthResponse> signInWithOpenIDConnect(
    OpenIDConnectCredentials oidc,
  ) async {
    final body = {
      'id_token': oidc.idToken,
      'nonce': oidc.nonce,
      'client_id': oidc.clientId,
      'issuer': oidc.issuer,
      'provider': oidc.provider?.name(),
    };
    final fetchOptions = GotrueRequestOptions(
        headers: headers, body: body, query: {'grant_type': 'id_token'});

    final response = await _fetch.request(
      '$url/token',
      RequestMethodType.post,
      options: fetchOptions,
    );
    return AuthResponse.fromJson(response);
  }

  /// Send User supplied Mobile OTP to be verified
  ///
  /// [phone] is the user's phone number WITH international prefix
  ///
  /// [token] is the token that user was sent to their mobile phone
  Future<AuthResponse> verifyMobileOTP(
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
    final fetchOptions = GotrueRequestOptions(headers: headers, body: body);
    final response = await _fetch.request('$url/verify', RequestMethodType.post,
        options: fetchOptions);
    final authResponse = AuthResponse.fromJson(response);
    Session session = authResponse.session!;
    // if the user in the current session is null, we get the user based on
    // the session's jwt token
    if (session.user == null) {
      final userResponse = await getUser(session.accessToken);
      session = session.copyWith(user: userResponse.user);
    }
    return authResponse;
  }

  /// Sends an invite link to an email address.
  Future<UserResponse> inviteUserByEmail(
    String email, {
    AuthOptions? options,
  }) async {
    final body = {'email': email};
    final urlParams = <String, String>{};
    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams['redirect_to'] = encodedRedirectTo;
    }
    final fetchOptions = GotrueRequestOptions(
      headers: headers,
      body: body,
      query: urlParams,
    );

    final response = await _fetch.request(
      '$url/invite',
      RequestMethodType.post,
      options: fetchOptions,
    );
    return UserResponse.fromJson(response);
  }

  /// Generates links to be sent via email or other.
  Future<GenerateLinkResponse> generateLink(
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

    final fetchOptions = GotrueRequestOptions(headers: headers, body: body);

    final response = await _fetch.request(
      '$url/admin/generate_link',
      RequestMethodType.post,
      options: fetchOptions,
    );
    return GenerateLinkResponse.fromJson(response);
  }

  /// Sends a reset request to an email address.
  Future<void> resetPasswordForEmail(
    String email, {
    AuthOptions? options,
  }) async {
    final body = {
      'email': email,
      'gotrue_meta_security': {'hcaptcha_token': options?.captchaToken},
    };
    final urlParams = <String, String>{};
    if (options?.redirectTo != null) {
      final encodedRedirectTo = Uri.encodeComponent(options!.redirectTo!);
      urlParams['redirect_to'] = encodedRedirectTo;
    }

    final fetchOptions =
        GotrueRequestOptions(headers: headers, body: body, query: urlParams);
    await _fetch.request(
      '$url/recover',
      RequestMethodType.post,
      options: fetchOptions,
    );
  }

  /// Removes a logged-in session.
  Future<void> signOut(String jwt) async {
    final headers = {...this.headers};
    headers['Authorization'] = 'Bearer $jwt';
    final options = GotrueRequestOptions(headers: headers, noResolveJson: true);
    await _fetch.request(
      '$url/logout',
      RequestMethodType.post,
      options: options,
    );
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
  Future<UserResponse> getUser(String jwt) async {
    final headers = {...this.headers};
    headers['Authorization'] = 'Bearer $jwt';
    final options = GotrueRequestOptions(headers: headers);
    final response = await _fetch.request('$url/user', RequestMethodType.get,
        options: options);
    return UserResponse.fromJson(response);
  }

  /// Updates the user data.
  Future<UserResponse> updateUser(
    String jwt,
    UserAttributes attributes,
  ) async {
    final body = attributes.toJson();
    final headers = {...this.headers};
    headers['Authorization'] = 'Bearer $jwt';
    final options = GotrueRequestOptions(headers: headers, body: body);
    final response = await _fetch.request('$url/user', RequestMethodType.put,
        options: options);
    return UserResponse.fromJson(response);
  }

  /// Generates a new JWT.
  Future<AuthResponse> refreshAccessToken(
    String refreshToken, [
    String? jwt,
  ]) async {
    final body = {'refresh_token': refreshToken};
    if (jwt != null) {
      headers['Authorization'] = 'Bearer $jwt';
    }
    final options = GotrueRequestOptions(
        headers: headers, body: body, query: {'grant_type': 'refresh_token'});
    final response = await _fetch.request('$url/token', RequestMethodType.post,
        options: options);
    return AuthResponse.fromJson(response);
  }
}
