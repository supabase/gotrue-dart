import 'dart:convert';

import 'package:gotrue/src/fetch_options.dart';
import 'package:gotrue/src/gotrue_error.dart';
import 'package:gotrue/src/gotrue_response.dart';
import 'package:http/http.dart' as http;

final Fetch fetch = Fetch();

class Fetch {
  bool isSuccessStatusCode(int code) {
    return code >= 200 && code <= 299;
  }

  GotrueError handleError(dynamic error) {
    if (error is http.Response) {
      try {
        final parsedJson = json.decode(error.body) as Map<String, dynamic>;
        final message = parsedJson['msg'] ??
            parsedJson['message'] ??
            parsedJson['error_description'] ??
            parsedJson['error'] ??
            json.encode(parsedJson);
        return GotrueError(message as String);
      } on FormatException catch (_) {
        return GotrueError(error.body);
      }
    } else {
      return GotrueError(error.toString());
    }
  }

  Future<GotrueResponse> get(String url, {FetchOptions? options}) async {
    final client = http.Client();
    try {
      final headers = options?.headers ?? {};
      final http.Response response =
          await client.get(Uri.parse(url), headers: headers);
      if (isSuccessStatusCode(response.statusCode)) {
        if (options?.noResolveJson == true) {
          return GotrueResponse(rawData: response.body);
        } else {
          final jsonBody = json.decode(response.body);
          return GotrueResponse(rawData: jsonBody);
        }
      } else {
        throw response;
      }
    } catch (e) {
      return GotrueResponse(error: handleError(e));
    } finally {
      client.close();
    }
  }

  Future<GotrueResponse> post(
    String url,
    dynamic body, {
    FetchOptions? options,
  }) async {
    final client = http.Client();
    try {
      final bodyStr = json.encode(body ?? {});
      final headers = options?.headers ?? {};
      final http.Response response =
          await client.post(Uri.parse(url), headers: headers, body: bodyStr);
      if (isSuccessStatusCode(response.statusCode)) {
        if (options?.noResolveJson == true) {
          return GotrueResponse(rawData: response.body);
        } else {
          final jsonBody = json.decode(response.body);
          return GotrueResponse(rawData: jsonBody);
        }
      } else {
        throw response;
      }
    } catch (e) {
      return GotrueResponse(error: handleError(e));
    } finally {
      client.close();
    }
  }

  Future<GotrueResponse> put(
    String url,
    dynamic body, {
    FetchOptions? options,
  }) async {
    final client = http.Client();
    try {
      final bodyStr = json.encode(body ?? {});
      final headers = options?.headers ?? {};
      final http.Response response =
          await client.put(Uri.parse(url), headers: headers, body: bodyStr);
      if (isSuccessStatusCode(response.statusCode)) {
        if (options?.noResolveJson == true) {
          return GotrueResponse(rawData: response.body);
        } else {
          final jsonBody = json.decode(response.body);
          return GotrueResponse(rawData: jsonBody);
        }
      } else {
        throw response;
      }
    } catch (e) {
      return GotrueResponse(error: handleError(e));
    } finally {
      client.close();
    }
  }
}
