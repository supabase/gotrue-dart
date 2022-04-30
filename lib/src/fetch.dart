import 'dart:convert';

import 'package:gotrue/src/fetch_options.dart';
import 'package:gotrue/src/gotrue_error.dart';
import 'package:gotrue/src/gotrue_response.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:universal_io/io.dart';

class Fetch {
  final Client? httpClient;

  Fetch([this.httpClient]);

  bool isSuccessStatusCode(int code) {
    return code >= 200 && code <= 299;
  }

  GotrueResponse handleError(dynamic error) {
    int? statusCode;
    GotrueError errorRes;
    if (error is http.Response) {
      statusCode = error.statusCode;
    }

    if (error is http.Response) {
      try {
        final parsedJson = json.decode(error.body) as Map<String, dynamic>;
        final message = parsedJson['msg'] ??
            parsedJson['message'] ??
            parsedJson['error_description'] ??
            parsedJson['error'] ??
            json.encode(parsedJson);
        errorRes = GotrueError(message as String);
      } on FormatException catch (_) {
        errorRes = GotrueError(error.body);
      }
    } else if (error is SocketException) {
      errorRes = GotrueError(
        error.toString(),
        statusCode: error.runtimeType.toString(),
      );
    } else {
      errorRes = GotrueError(error.toString());
    }

    return GotrueResponse(error: errorRes, statusCode: statusCode);
  }

  Future<GotrueResponse> get(String url, {FetchOptions? options}) async {
    try {
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
        throw response;
      }
    } catch (e) {
      return handleError(e);
    }
  }

  Future<GotrueResponse> post(
    String url,
    dynamic body, {
    FetchOptions? options,
  }) async {
    try {
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
        throw response;
      }
    } on SocketException catch (e) {
      return handleError(e);
    } catch (e) {
      return handleError(e);
    }
  }

  Future<GotrueResponse> put(
    String url,
    dynamic body, {
    FetchOptions? options,
  }) async {
    try {
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
        throw response;
      }
    } catch (e) {
      return handleError(e);
    }
  }
}
