import 'package:gotrue/gotrue.dart';

void main(List<String> arguments) async {
  const gotrueUrl = 'http://localhost:9999';
  const annonToken = '';
  final client = GoTrueClient(url: gotrueUrl, headers: {
    'Authorization': 'Bearer $annonToken',
    'apikey': annonToken,
  });

  final login = await client.signIn(
    email: 'email',
    password: '12345',
  );

  if (login.error == null) {
    print('Logged in, uid: ${login.data!.user!.id}');
  } else {
    print('Error!');
  }
}
