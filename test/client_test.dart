import 'dart:convert';

import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/user_attributes.dart';
import 'package:test/test.dart';

void main() {
  const gotrueUrl = 'http://localhost:9999';
  const annonToken = '';
  final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  final email = 'fake$timestamp@email.com';
  const password = 'secret';

  late GoTrueClient client;

  setUp(() {
    client = GoTrueClient(url: gotrueUrl, headers: {
      'Authorization': 'Bearer $annonToken',
      'apikey': annonToken,
    });
  });

  test('basic json parsing', () async {
    const body =
        '{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjExODk1MzExLCJzdWIiOiI0Njg3YjkzNi02ZDE5LTRkNmUtOGIyYi1kYmU0N2I1ZjYzOWMiLCJlbWFpbCI6InRlc3Q5QGdtYWlsLmNvbSIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIn0sInVzZXJfbWV0YWRhdGEiOm51bGwsInJvbGUiOiJhdXRoZW50aWNhdGVkIn0.GyIokEvKGp0M8PYU8IiIpvzeTAXspoCtR5aj-jCnWys","token_type":"bearer","expires_in":3600,"refresh_token":"gnqAPZwZDj_XCYMF7U2Xtg","user":{"id":"4687b936-6d19-4d6e-8b2b-dbe47b5f639c","aud":"authenticated","role":"authenticated","email":"test9@gmail.com","confirmed_at":"2021-01-29T03:41:51.026791085Z","last_sign_in_at":"2021-01-29T03:41:51.032154484Z","app_metadata":{"provider":"email"},"user_metadata":null,"created_at":"2021-01-29T03:41:51.022787Z","updated_at":"2021-01-29T03:41:51.033826Z"}}';
    final bodyJson = json.decode(body);
    final session = Session.fromJson(bodyJson as Map<String, dynamic>);

    expect(session, isNotNull);
    expect(session.accessToken,
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjExODk1MzExLCJzdWIiOiI0Njg3YjkzNi02ZDE5LTRkNmUtOGIyYi1kYmU0N2I1ZjYzOWMiLCJlbWFpbCI6InRlc3Q5QGdtYWlsLmNvbSIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIn0sInVzZXJfbWV0YWRhdGEiOm51bGwsInJvbGUiOiJhdXRoZW50aWNhdGVkIn0.GyIokEvKGp0M8PYU8IiIpvzeTAXspoCtR5aj-jCnWys');
  });

  test('signUp()', () async {
    final response = await client.signUp(email, password);
    final data = response.data;
    final error = response.error;
    expect(error, isNull);
    expect(data?.accessToken is String, true);
    expect(data?.refreshToken is String, true);
    expect(data?.user?.id is String, true);
  });

  test('signIn()', () async {
    final response = await client.signIn(email: email, password: password);
    final data = response.data!;
    final error = response.error;
    expect(error, isNull);
    expect(data.accessToken is String, true);
    expect(data.refreshToken is String, true);
    expect(data.user?.id is String, true);
  });

  test('Get user', () async {
    final user = client.user();
    expect(user?.id is String, true);
    expect(user?.appMetadata['provider'], 'email');
  });

  test('Update user', () async {
    final response =
        await client.update(UserAttributes(data: {'hello': 'world'}));
    final data = response.data;
    final error = response.error;
    expect(error, isNull);
    expect(data?.id is String, true);
    expect(data?.userMetadata['hello'], 'world');
  });

  test('Get user after updating', () async {
    final user = client.user();
    expect(user?.id is String, true);
    expect(user?.userMetadata['hello'], 'world');
  });

  test('signOut', () async {
    final res = await client.signOut();
    expect(res.error, isNull);
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
}
