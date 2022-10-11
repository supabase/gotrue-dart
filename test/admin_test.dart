import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart' show env, load;
import 'package:gotrue/gotrue.dart';
import 'package:test/test.dart';

void main() {
  final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

  load(); // Load env variables from .env file

  final gotrueUrl = env['GOTRUE_URL'] ?? 'http://localhost:9998';
  final anonToken = env['GOTRUE_TOKEN'] ?? 'anonKey';
  final email = env['GOTRUE_USER_EMAIL'] ?? 'fake$timestamp@email.com';
  final phone = env['GOTRUE_USER_PHONE'] ?? '+1 666-0000-0000';
  final password = env['GOTRUE_USER_PASS'] ?? 'secret';

  final serviceRoleToken = JWT(
    {
      'role': 'service_role',
    },
  ).sign(
    SecretKey(
        env['GOTRUE_JWT_SECRET'] ?? '37c304f8-51aa-419a-a1af-06154e63707a'),
  );

  group('Client with default http client', () {
    late GoTrueClient client;

    setUpAll(() {
      client = GoTrueClient(
        url: gotrueUrl,
        headers: {
          'Authorization': 'Bearer $anonToken',
          'apikey': anonToken,
        },
      );
    });

    test('', () {});
  });
}
