import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/fetch.dart';
import 'package:gotrue/src/types/fetch_options.dart';
import 'package:http/http.dart';

class GoTrueAdminApi {
  final String _url;
  final Map<String, String> _headers;

  final Client? _httpClient;
  late final GotrueFetch _fetch = GotrueFetch(_httpClient);

  GoTrueAdminApi(
    this._url, {
    Map<String, String>? headers,
    Client? httpClient,
  })  : _headers = headers ?? {},
        _httpClient = httpClient;

  /// Removes a logged-in session.
  Future<void> signOut(String jwt) async {
    final headers = {..._headers};
    headers['Authorization'] = 'Bearer $jwt';
    final options = GotrueRequestOptions(headers: headers, noResolveJson: true);
    await _fetch.request(
      '$_url/logout',
      RequestMethodType.post,
      options: options,
    );
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
      headers: _headers,
      body: body,
      query: urlParams,
    );

    final response = await _fetch.request(
      '$_url/invite',
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

    final fetchOptions = GotrueRequestOptions(headers: _headers, body: body);

    final response = await _fetch.request(
      '$_url/admin/generate_link',
      RequestMethodType.post,
      options: fetchOptions,
    );
    return GenerateLinkResponse.fromJson(response);
  }

  /// Gets the user by their id.
  Future<UserResponse> getUserById(String uid) async {
    final options = GotrueRequestOptions(headers: _headers);
    final response = await _fetch.request(
      '$_url/admin/users/$uid',
      RequestMethodType.get,
      options: options,
    );
    return UserResponse.fromJson(response);
  }

  /// Updates the user data.
  Future<UserResponse> updateUserById({
    required String uid,
    required UserAttributes attributes,
  }) async {
    final body = attributes.toJson();
    final options = GotrueRequestOptions(headers: _headers, body: body);
    final response = await _fetch.request(
      '$_url/admin/users/$uid',
      RequestMethodType.put,
      options: options,
    );
    return UserResponse.fromJson(response);
  }
}
