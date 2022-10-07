import 'dart:convert';
import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
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
  final phone = env['GOTRUE_USER_PHONE'] ?? '+1 666-0000-0000';
  final password = env['GOTRUE_USER_PASS'] ?? 'secret';

  final serviceRoleToken = JWT(
    {
      'role': 'service_role',
    },
  ).sign(
    SecretKey(
      env['GOTRUE_JWT_SECRET'] ?? '37c304f8-51aa-419a-a1af-06154e63707a',
    ),
  );

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
        session!.accessToken,
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjExODk1MzExLCJzdWIiOiI0Njg3YjkzNi02ZDE5LTRkNmUtOGIyYi1kYmU0N2I1ZjYzOWMiLCJlbWFpbCI6InRlc3Q5QGdtYWlsLmNvbSIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIn0sInVzZXJfbWV0YWRhdGEiOm51bGwsInJvbGUiOiJhdXRoZW50aWNhdGVkIn0.GyIokEvKGp0M8PYU8IiIpvzeTAXspoCtR5aj-jCnWys',
      );
    });

    test('signUp()', () async {
      final response = await client.signUp(
        email: email,
        password: password,
        options: AuthOptions(redirectTo: 'https://localhost:9998/welcome'),
        userMetadata: {"Hello": "World"},
      );
      final data = response.session;
      expect(data?.accessToken, isA<String>());
      expect(data?.refreshToken, isA<String>());
      expect(data?.user?.id, isA<String>());
      expect(data?.user?.userMetadata, {"Hello": "World"});
    });

    test('signUp() with autoConfirm off', () async {
      final response = await clientWithAuthConfirmOff.signUp(
        email: email,
        password: password,
        options: AuthOptions(redirectTo: 'https://localhost:9999/welcome'),
      );
      expect(response.user, isA<User>());
      expect(response.session, isNull);
    });

    test('signUp() with email should throw error if used twice', () async {
      final localEmail = email;

      try {
        await client.signUp(email: localEmail, password: password);
      } catch (error) {
        expect(error, isA<AuthException>());
      }
    });

    test('signUp with phone', () async {
      try {
        print(phone);
        await client.signUp(phone: phone, password: password);
        fail('signIn with phone did not throw');
      } catch (error) {
        expect(error, isA<AuthException>());
      }
    });

    test('signIn()', () async {
      final response =
          await client.signInWithPassword(email: email, password: password);
      final data = response.session;

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
      final response = await client.updateUser(
        UserAttributes(data: {
          'hello': 'world',
          'japanese': '日本語',
          'korean': '한국어',
          'arabic': 'عربى',
        }),
      );
      final user = response.user;
      expect(user?.id, isA<String>());
      expect(user?.userMetadata?['hello'], 'world');
      expect(client.currentSession?.user?.userMetadata?['hello'], 'world');
    });

    test('Get user after updating', () async {
      final user = client.currentUser;
      expect(user, isNotNull);
      expect(user?.id, isA<String>());
      expect(user?.userMetadata?['hello'], 'world');
      expect(user?.userMetadata?['japanese'], '日本語');
      expect(user?.userMetadata?['korean'], '한국어');
      expect(user?.userMetadata?['arabic'], 'عربى');
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
        final res = await client.signInWithPassword(
          email: email,
          password: 'wrong_$password',
        );
        final data = res.session;
        expect(data, isNull);
      } on AuthException catch (error) {
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
        await client.signInWithPassword(email: email, password: password);
      } catch (error) {
        expect(error, isA<AuthException>());
        expect((error as AuthException).statusCode, '420');
      }
    });
  });

  group('header', () {
    // test('X-Client-Info is set', () {
    //   final client = GoTrueClient(
    //     url: gotrueUrl,
    //     headers: {
    //       'Authorization': 'Bearer $anonToken',
    //       'apikey': anonToken,
    //     },
    //   );

    //   expect(
    //     client._headers['X-Client-Info']!.split('/').first,
    //     'gotrue-dart',
    //   );
    // });

    // test('X-Client-Info can be overridden', () {
    //   final client = GoTrueClient(
    //     url: gotrueUrl,
    //     headers: {
    //       'Authorization': 'Bearer $anonToken',
    //       'apikey': anonToken,
    //       'X-Client-Info': 'supabase-dart/0.0.0'
    //     },
    //   );

    //   expect(client._headers['X-Client-Info'], 'supabase-dart/0.0.0');
    // });
  });

  group('server api tests', () {
    late final GoTrueClient serviceRoleApiClient;

    final unregistredUserEmail = 'new${Random.secure().nextInt(4096)}@fake.org';

    setUpAll(() {
      serviceRoleApiClient = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'Authorization': 'Bearer $serviceRoleToken',
          'apikey': serviceRoleToken,
        },
      );
    });

    test(
        'generateLink() supports signUp with generate confirmation signup link ',
        () async {
      final authOptions =
          AuthOptions(redirectTo: 'http://localhost:9999/welcome');

      const userMetadata = {'status': 'alpha'};

      final response = await serviceRoleApiClient.admin.generateLink(
        unregistredUserEmail,
        InviteType.signup,
        password: password,
        userMetadata: userMetadata,
        options: authOptions,
      );

      expect(response.user, isNotNull);

      final actionLink = response.properties.actionLink;

      final actionUri = Uri.tryParse(actionLink);
      expect(actionUri, isNotNull);

      expect(actionUri!.queryParameters['token'], isNotEmpty);
      expect(actionUri.queryParameters['type'], isNotEmpty);
      expect(actionUri.queryParameters['redirect_to'], authOptions.redirectTo);
      // expect(response.data!['user_metadata'], userMetadata);
    });
  });
}
