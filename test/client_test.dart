import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/user_attributes.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:test/test.dart';

void main(List<String> arguments) {
  final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

  final parser = ArgParser();

  parser.addOption(
    'url',
    abbr: 'u',
    defaultsTo: 'http://localhost:9999',
    help: 'The URL of a GoTrue server instance for testing against.',
  );
  parser.addOption(
    'token',
    abbr: 't',
    defaultsTo: '',
    help: 'Anonymous access token for the GoTrue server.',
  );
  parser.addOption(
    'email',
    abbr: 'e',
    defaultsTo: 'fake$timestamp@email.com',
    help:
        'Email address to be used to create a new user account on the GoTrue server.\nBy default, a unique address is generated based on the current timestamp.',
  );
  parser.addOption(
    'password',
    abbr: 'p',
    defaultsTo: 'secret',
    help:
        'Password to be used to create a new user account on the GoTrue server.',
  );
  parser.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show this help info.',
  );

  final args = parser.parse(arguments);

  if (args['help'] == true) {
    print(parser.usage);
    exit(0);
  }

  final gotrueUrl = args['url'].toString();
  final annonToken = args['token'].toString();
  final email = args['email'].toString();
  final password = args['password'].toString();

  group('client', () {
    late GoTrueClient client;

    setUpAll(() {
      client = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'Authorization': 'Bearer $annonToken',
          'apikey': annonToken,
        },
      );
    });

    test('basic json parsing', () async {
      const body =
          '{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjExODk1MzExLCJzdWIiOiI0Njg3YjkzNi02ZDE5LTRkNmUtOGIyYi1kYmU0N2I1ZjYzOWMiLCJlbWFpbCI6InRlc3Q5QGdtYWlsLmNvbSIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIn0sInVzZXJfbWV0YWRhdGEiOm51bGwsInJvbGUiOiJhdXRoZW50aWNhdGVkIn0.GyIokEvKGp0M8PYU8IiIpvzeTAXspoCtR5aj-jCnWys","token_type":"bearer","expires_in":3600,"refresh_token":"gnqAPZwZDj_XCYMF7U2Xtg","user":{"id":"4687b936-6d19-4d6e-8b2b-dbe47b5f639c","aud":"authenticated","role":"authenticated","email":"test9@gmail.com","confirmed_at":"2021-01-29T03:41:51.026791085Z","last_sign_in_at":"2021-01-29T03:41:51.032154484Z","app_metadata":{"provider":"email"},"user_metadata":null,"created_at":"2021-01-29T03:41:51.022787Z","updated_at":"2021-01-29T03:41:51.033826Z"}}';
      final bodyJson = json.decode(body);
      final session = Session.fromJson(bodyJson as Map<String, dynamic>);

      expect(session, isNotNull);
      expect(
        session.accessToken,
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjExODk1MzExLCJzdWIiOiI0Njg3YjkzNi02ZDE5LTRkNmUtOGIyYi1kYmU0N2I1ZjYzOWMiLCJlbWFpbCI6InRlc3Q5QGdtYWlsLmNvbSIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIn0sInVzZXJfbWV0YWRhdGEiOm51bGwsInJvbGUiOiJhdXRoZW50aWNhdGVkIn0.GyIokEvKGp0M8PYU8IiIpvzeTAXspoCtR5aj-jCnWys',
      );
    });

    test('signUp()', () async {
      final response = await client.signUp(
        email,
        password,
        options: AuthOptions(redirectTo: 'https://localhost:9999/welcome'),
      );
      final data = response.data;
      final error = response.error;
      expect(error?.message, isNull);
      expect(data?.accessToken, isA<String>());
      expect(data?.refreshToken, isA<String>());
      expect(data?.user?.id, isA<String>());
    });

    test('signIn()', () async {
      final response = await client.signIn(email: email, password: password);
      final data = response.data;
      final error = response.error;

      expect(error?.message, isNull);
      expect(data?.accessToken, isA<String>());
      expect(data?.refreshToken, isA<String>());
      expect(data?.user?.id, isA<String>());

      final payload = Jwt.parseJwt(data!.accessToken);
      final persistSession = json.decode(data.persistSessionString);
      // ignore: avoid_dynamic_calls
      expect(payload['exp'], persistSession['expiresAt']);
    });

    test('Get user', () async {
      final user = client.user();
      expect(user?.id, isA<String>());
      expect(user?.appMetadata['provider'], 'email');
    });

    test('Set auth', () async {
      final jwt = client.currentSession?.accessToken ?? '';
      expect(jwt, isNotEmpty);

      final newClient = GoTrueClient(url: gotrueUrl, autoRefreshToken: false);

      expect(newClient.currentSession?.accessToken, isNot(equals(jwt)));
      newClient.setAuth(jwt);
      expect(newClient.currentSession?.accessToken, equals(jwt));
    });

    test('Update user', () async {
      final response =
          await client.update(UserAttributes(data: {'hello': 'world'}));
      final data = response.data;
      final error = response.error;
      expect(error?.message, isNull);
      expect(data?.id, isA<String>());
      expect(data?.userMetadata['hello'], 'world');
    });

    test('Get user after updating', () async {
      final user = client.user();
      expect(user?.id, isA<String>());
      expect(user?.userMetadata['hello'], 'world');
    });

    test('signOut', () async {
      final res = await client.signOut();
      expect(res.error?.message, isNull);
    });

    test('Get user after logging out', () async {
      final user = client.user();
      expect(user, isNull);
    });

    test('signIn() with the wrong password', () async {
      final res = await client.signIn(
        email: email,
        password: '${password}2',
      );
      final data = res.data;
      final error = res.error!;
      expect(error.message, isNotNull);
      expect(data, isNull);
    });
  });

  group('header', () {
    test('X-Client-Info is set', () {
      final client = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'Authorization': 'Bearer $annonToken',
          'apikey': annonToken,
        },
      );

      expect(
        client.api.headers['X-Client-Info']!.split('/').first,
        'gotrue-dart',
      );
    });

    test('X-Client-Info can be overridden', () {
      final client = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'Authorization': 'Bearer $annonToken',
          'apikey': annonToken,
          'X-Client-Info': 'supabase-dart/0.0.0'
        },
      );

      expect(client.api.headers['X-Client-Info'], 'supabase-dart/0.0.0');
    });
  });
}
