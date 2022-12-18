// part of 'gotrue_client.dart';

import 'fetch.dart';
import 'types/fetch_options.dart';
import 'types/mfa.dart';

class GoTrueAdminMFAApi {
  final String _url;
  final Map<String, String> _headers;
  final GotrueFetch fetch;

  GoTrueAdminMFAApi({
    required String url,
    required Map<String, String> headers,
    required this.fetch,
  })  : _url = url,
        _headers = headers;

  Future<AuthMFAAdminListFactorsResponse> listFactors(String userId) async {
    final data = await fetch.request(
      '$_url/admin/users/$userId/factors',
      RequestMethodType.get,
      options: GotrueRequestOptions(
        headers: _headers,
      ),
    );

    return AuthMFAAdminListFactorsResponse.fromJson(data);
  }

  Future<AuthMFAAdminDeleteFactorResponse> deleteFactor(
      String userId, String factorId) async {
    final data = await fetch.request(
      '$_url/admin/users/$userId/factors/$factorId',
      RequestMethodType.delete,
      options: GotrueRequestOptions(
        headers: _headers,
      ),
    );

    return AuthMFAAdminDeleteFactorResponse.fromJson(data);
  }
}
