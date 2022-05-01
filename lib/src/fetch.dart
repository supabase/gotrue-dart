import 'dart:convert';

import 'package:gotrue/src/fetch_options.dart';
import 'package:gotrue/src/gotrue_error.dart';
import 'package:gotrue/src/gotrue_response.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Fetch {
  final Client? httpClient;

  Fetch([this.httpClient]);

  bool isSuccessStatusCode(int code) {
    return code >= 200 && code <= 299;
  }

  GotrueError _handleError(http.Response error) {
    late GotrueError errorRes;

    try {
      final parsedJson = json.decode(error.body) as Map<String, dynamic>;
      final String message = (parsedJson['msg'] ??
              parsedJson['message'] ??
              parsedJson['error_description'] ??
              parsedJson['error'] ??
              error.body)
          .toString();
      errorRes = GotrueError(message);
    } catch (_) {
      errorRes = GotrueError(error.body);
    }

    return errorRes;
  }

  Future<GotrueResponse> get(String url, {FetchOptions? options}) async {
    final headers = options?.headers ?? {};
    final http.Response response = await (httpClient?.get ?? http.get)(
      Uri.parse(url),
      headers: headers,
    );
    if (isSuccessStatusCode(response.statusCode)) {
      if (options?.noResolveJson == true) {
        return GotrueResponse(
          rawData: response.body,
          statusCode: response.statusCode,
        );
      } else {
        final jsonBody = json.decode(response.body);
        return GotrueResponse(
          rawData: jsonBody,
          statusCode: response.statusCode,
        );
      }
    } else {
      throw _handleError(response);
    }
  }

  Future<GotrueResponse> post(
    String url,
    dynamic body, {
    FetchOptions? options,
  }) async {
    final bodyStr = json.encode(body ?? {});
    final headers = options?.headers ?? {};
    final http.Response response = await (httpClient?.post ?? http.post)(
      Uri.parse(url),
      headers: headers,
      body: bodyStr,
    );
    if (isSuccessStatusCode(response.statusCode)) {
      if (options?.noResolveJson == true) {
        return GotrueResponse(
          rawData: response.body,
          statusCode: response.statusCode,
        );
      } else {
        final jsonBody = json.decode(response.body);
        return GotrueResponse(
          rawData: jsonBody,
          statusCode: response.statusCode,
        );
      }
    } else {
      throw _handleError(response);
    }
  }

  Future<GotrueResponse> put(
    String url,
    dynamic body, {
    FetchOptions? options,
  }) async {
    final bodyStr = json.encode(body ?? {});
    final headers = options?.headers ?? {};
    final http.Response response = await (httpClient?.put ?? http.put)(
      Uri.parse(url),
      headers: headers,
      body: bodyStr,
    );
    if (isSuccessStatusCode(response.statusCode)) {
      if (options?.noResolveJson == true) {
        return GotrueResponse(
          rawData: response.body,
          statusCode: response.statusCode,
        );
      } else {
        final jsonBody = json.decode(response.body);
        return GotrueResponse(
          rawData: jsonBody,
          statusCode: response.statusCode,
        );
      }
    } else {
      throw _handleError(response);
    }
  }
}
