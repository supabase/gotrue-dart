import 'package:dotenv/dotenv.dart' show env, load;
import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/types/mfa.dart';
import 'package:http/http.dart' as http;
import 'package:otp/otp.dart';
import 'package:test/test.dart';

void main() {
  load(); // Load env variables from .env file

  final gotrueUrl = env['GOTRUE_URL'] ?? 'http://localhost:9998';

  final anonToken = env['GOTRUE_TOKEN'] ?? 'anonKey';
  // final email = env['GOTRUE_USER_EMAIL'] ?? 'fake$timestamp@email.com';
  final password = 'secret';

  late GoTrueClient client;
  setUp(() async {
    final res = await http.post(
        Uri.parse("http://localhost:3000/rpc/reset_and_init_auth_data"),
        headers: {'x-forwarded-for': '127.0.0.1'});
    // final res2 = await http.post(Uri.parse("http://localhost:3000/rpc/test"));
    print(res.body);
    // print(res2.body);

    client = GoTrueClient(
      url: gotrueUrl,
      headers: {
        'Authorization': 'Bearer $anonToken',
        'apikey': anonToken,
        'x-forwarded-for': '127.0.0.1'
      },
    );
  });

  test('enroll', () async {
    await client.signInWithPassword(
        password: password, email: "fake1@email.com");

    final res = await client.mfa
        .enroll(issuer: "MyFriend", friendlyName: "MyFriendName");
    final uri = Uri.parse(res.totp.uri);
    print(uri);
    expect(res.type, FactorType.totp);
    expect(uri.queryParameters["issuer"], "MyFriend");
    expect(uri.scheme, "otpauth");
  });

  test('challenge', () async {
    await client.signInWithPassword(
        password: password, email: "fake1@email.com");
    final factorId = "0d3aa138-da96-4aea-8217-af07daa6b82d";
    final res = await client.mfa.challenge(factorId: factorId);
    expect(res.expiresAt.isAfter(DateTime.now()), true);
  });

  test('verify', () async {
    await client.signInWithPassword(
        password: password, email: "fake1@email.com");

    final factorId = "0d3aa138-da96-4aea-8217-af07daa6b82d";
    final secret = "R7K3TR4HN5XBOCDWHGGUGI2YYGQSCLUS";
    final challengeId = "b824ca10-cc13-4250-adba-20ee6e5e7dcd";

    final code = OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1, isGoogle: true);

    final res = await client.mfa
        .verify(factorId: factorId, challengeId: challengeId, code: code);

    expect(client.currentSession?.accessToken, res.accessToken);
    expect(client.currentUser, res.user);
    expect(client.currentSession?.refreshToken, res.refreshToken);
    expect(client.currentSession?.expiresIn, res.expiresIn.inSeconds);
  });

  test("challenge and verify", () async {
    await client.signInWithPassword(
        password: password, email: "fake1@email.com");

    final factorId = "0d3aa138-da96-4aea-8217-af07daa6b82d";
    final secret = "R7K3TR4HN5XBOCDWHGGUGI2YYGQSCLUS";

    final code = OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1, isGoogle: true);

    final res =
        await client.mfa.challengeAndVerify(factorId: factorId, code: code);
    expect(client.currentUser, res.user);
  });
}
