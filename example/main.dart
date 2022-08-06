import 'package:gotrue/gotrue.dart';

Future<bool> main(List<String> arguments) async {
  const gotrueUrl = 'http://localhost:9999';
  const annonToken = '';
  final client = GoTrueClient(
    url: gotrueUrl,
    headers: {
      'Authorization': 'Bearer $annonToken',
      'apikey': annonToken,
    },
  );

  try {
    final login = await client.signIn(
      email: 'email',
      password: '12345',
    );
    print('Logged in, uid: ${login.data!.user!.id}');
  } on GoTrueException catch (error) {
    print('Sign in Error: ${error.message}');
  }

  await client.signOut();
  print('Logged out!');
  return true;
}
