import 'dart:convert';

import 'package:http/http.dart' as http;

import 'fetch_options.dart';
import 'gotrue_error.dart';
import 'gotrue_response.dart';

final Fetch fetch = Fetch();

class Fetch {
  GotrueError handleError(dynamic error) {
    if (error is http.Response) {
      try {
        final errorJson = json.decode(error.body);
        final message = errorJson['msg'] ??
            errorJson['message'] ??
            errorJson['error_description'] ??
            errorJson['error'] ??
            json.encode(errorJson);
        return GotrueError(message as String);
      } on FormatException catch (_) {
        return GotrueError(error.body);
      }
    } else {
      return GotrueError(error.toString());
    }
  }

  Future<GotrueResponse> get(String url, {FetchOptions options}) async {
    try {
      final client = http.Client();
      final headers = options?.headers ?? {};
      final http.Response response = await client.post(url, headers: headers);
      if (response.statusCode == 200) {
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
    }
  }

  Future<GotrueResponse> post(String url, dynamic body,
      {FetchOptions options}) async {
    try {
      final client = http.Client();
      final bodyStr = json.encode(body ?? {});
      final headers = options?.headers ?? {};
      final http.Response response =
          await client.post(url, headers: headers, body: bodyStr);
      if (response.statusCode == 200) {
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
    }
  }

  Future<GotrueResponse> put(String url, dynamic body,
      {FetchOptions options}) async {
    try {
      final client = http.Client();
      final bodyStr = json.encode(body ?? {});
      final headers = options?.headers ?? {};
      final http.Response response =
          await client.put(url, headers: headers, body: bodyStr);
      if (response.statusCode == 200) {
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
    }
  }
}
