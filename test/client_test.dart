import 'dart:convert';

import 'package:dotenv/dotenv.dart' show env, load;
import 'package:gotrue/gotrue.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:test/test.dart';

import 'custom_http_client.dart';

void main() {
  final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

  load(); // Load env variables from .env file

  final gotrueUrl = env['GOTRUE_URL'] ?? 'http://localhost:9998';
  final gotrueUrlWithAutoConfirmOff =
      env['GOTRUE_URL'] ?? 'http://localhost:9999';
  final anonToken = env['GOTRUE_TOKEN'] ?? '';
  final email = env['GOTRUE_USER_EMAIL'] ?? 'fake$timestamp@email.com';
  final password = env['GOTRUE_USER_PASS'] ?? 'secret';

  group('Client with default http client', () {
    late GoTrueClient client;
    late GoTrueClient clientWithAuthConfirmOff;

    setUpAll(() {
      client = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'Authorization': 'Bearer $anonToken',
          'apikey': anonToken,
        },
      );
      clientWithAuthConfirmOff = GoTrueClient(
        url: gotrueUrlWithAutoConfirmOff,
        headers: {
          'Authorization': 'Bearer $anonToken',
          'apikey': anonToken,
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
        options: AuthOptions(redirectTo: 'https://localhost:9998/welcome'),
        userMetadata: {"Hello": "World"},
      );
      final data = response.data;
      expect(data?.accessToken, isA<String>());
      expect(data?.refreshToken, isA<String>());
      expect(data?.user?.id, isA<String>());
      expect(data?.user?.userMetadata, {"Hello": "World"});
    });

    test('signUp() with autoConfirm off', () async {
      try {
        await clientWithAuthConfirmOff.signUp(
          email,
          password,
          options: AuthOptions(redirectTo: 'https://localhost:9999/welcome'),
        );
      } catch (error) {
        expect(error, isA<GotrueError>());
      }
    });

    test('signIn()', () async {
      final response = await client.signIn(email: email, password: password);
      final data = response.data;

      expect(data?.accessToken, isA<String>());
      expect(data?.refreshToken, isA<String>());
      expect(data?.user?.id, isA<String>());

      final payload = Jwt.parseJwt(data!.accessToken);
      final persistSession = json.decode(data.persistSessionString);
      // ignore: avoid_dynamic_calls
      expect(payload['exp'], persistSession['expiresAt']);
    });

    test('Get user', () async {
      final user = client.currentUser;
      expect(user, isNotNull);
      expect(user!.id, isA<String>());
      expect(user.appMetadata['provider'], 'email');
    });

    test('Set auth', () async {
      final jwt = client.currentSession?.accessToken ?? '';
      expect(jwt, isNotEmpty);

      final newClient = GoTrueClient(url: gotrueUrl, autoRefreshToken: false);

      expect(newClient.currentSession?.accessToken, isNot(equals(jwt)));
      newClient.setAuth(jwt);
      expect(newClient.currentSession?.accessToken, equals(jwt));
    });

    test('Set session', () async {
      final refreshToken = client.currentSession?.refreshToken ?? '';
      expect(refreshToken, isNotEmpty);

      final newClient = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'apikey': anonToken,
        },
      );

      expect(newClient.currentSession?.refreshToken ?? '', isEmpty);
      expect(newClient.currentSession?.accessToken ?? '', isEmpty);
      await newClient.setSession(refreshToken);
      expect(newClient.currentSession?.accessToken ?? '', isNotEmpty);
    });

    test('Update user', () async {
      final response = await client.update(
        UserAttributes(data: {'hello': 'world'}),
      );
      final data = response.data;
      expect(data?.id, isA<String>());
      expect(data?.userMetadata?['hello'], 'world');
      expect(client.currentSession?.user?.userMetadata?['hello'], 'world');
    });

    test('Get user after updating', () async {
      final user = client.currentUser;
      expect(user, isNotNull);
      expect(user?.id, isA<String>());
      expect(user?.userMetadata?['hello'], 'world');
    });

    test('signIn with OpenIDConnect wrong id_token', () async {
      try {
        const oidc = OpenIDConnectCredentials(
          idToken: "abcdf",
          nonce: "random value",
          provider: Provider.google,
        );
        await client.signIn(oidc: oidc);
        fail('Passed with wrong id token');
      } on GotrueError catch (error) {
        expect(error.message, isNotNull);
      }
    });

    test('signOut', () async {
      await client.signOut();
    });

    test('Get user after logging out', () async {
      final user = client.currentUser;
      expect(user, isNull);
    });

    test('signIn() with the wrong password', () async {
      try {
        final res = await client.signIn(
          email: email,
          password: '${password}2',
        );
        final data = res.data;
        expect(data, isNull);
      } on GotrueError catch (error) {
        expect(error.message, isNotNull);
      }
    });
  });

  group("Client with custom http client", () {
    late GoTrueClient client;

    setUpAll(() {
      client = GoTrueClient(
        url: gotrueUrl,
        httpClient: CustomHttpClient(),
      );
    });

    test('signIn()', () async {
      try {
        await client.signIn(email: email, password: password);
      } catch (error) {
        expect(error, isA<GotrueError>());
        expect((error as GotrueError).statusCode, '420');
      }
    });
  });

  group('header', () {
    test('X-Client-Info is set', () {
      final client = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'Authorization': 'Bearer $anonToken',
          'apikey': anonToken,
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
          'Authorization': 'Bearer $anonToken',
          'apikey': anonToken,
          'X-Client-Info': 'supabase-dart/0.0.0'
        },
      );

      expect(client.api.headers['X-Client-Info'], 'supabase-dart/0.0.0');
    });
  });
}
