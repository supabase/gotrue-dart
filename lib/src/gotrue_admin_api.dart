import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/fetch.dart';
import 'package:gotrue/src/types/auth_response.dart';
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
    final options =
        GotrueRequestOptions(headers: _headers, noResolveJson: true, jwt: jwt);
    await _fetch.request(
      '$_url/logout',
      RequestMethodType.post,
      options: options,
    );
  }

  // Requires either an email or phone
  Future<UserResponse> createUser(AdminUserAttributes attributes) async {
    final options = GotrueRequestOptions(
      headers: _headers,
      body: attributes.toJson(),
    );
    final response = await _fetch.request(
      '$_url/admin/users',
      RequestMethodType.post,
      options: options,
    );
    return UserResponse.fromJson(response);
  }

  Future<void> deleteUser(String id) async {
    final options = GotrueRequestOptions(headers: _headers);
    await _fetch.request(
      '$_url/admin/users/$id',
      RequestMethodType.delete,
      options: options,
    );
  }

  Future<List<UserResponse>> listUsers() async {
    final options = GotrueRequestOptions(headers: _headers);
    final response = await _fetch.request(
      '$_url/admin/users',
      RequestMethodType.get,
      options: options,
    );
    return (response["users"] as List)
        .map((e) => UserResponse.fromJson(e))
        .toList();
  }

  /// Sends an invite link to an email address.
  Future<UserResponse> inviteUserByEmail(
    String email, {
    String? redirectTo,
    Map<String, dynamic>? data,
  }) async {
    final body = {'email': email};
    final fetchOptions = GotrueRequestOptions(
      headers: _headers,
      body: body,
      redirectTo: redirectTo,
    );

    final response = await _fetch.request(
      '$_url/invite',
      RequestMethodType.post,
      options: fetchOptions,
    );
    return UserResponse.fromJson(response);
  }

  /// Generates links to be sent via email or other.
  Future<GenerateLinkResponse> generateLink({
    required GenerateLinkType type,
    required String email,
    String? password,
    Map<String, dynamic>? data,
    String? redirectTo,
  }) async {
    final body = {
      'email': email,
      'type': type.snakeCase,
      if (data != null) 'data': data,
      if (redirectTo != null) 'redirect_to': redirectTo,
      if (password != null) 'password': password,
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
  Future<UserResponse> updateUserById(
    String uid, {
    required AdminUserAttributes attributes,
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
