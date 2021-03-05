import 'package:gotrue/gotrue.dart';
import 'package:test/test.dart';

void main() {
  const gotrueUrl = 'http://localhost:9999';
  const annonToken = '';

  late GoTrueClient client;

  setUp(() {
    client = GoTrueClient(url: gotrueUrl, headers: {
      'Authorization': 'Bearer $annonToken',
      'apikey': annonToken,
    });
  });

  test('signIn() with Provider', () async {
    final res = await client.signIn(provider: Provider.google);
    final error = res.error;
    final url = res.url;
    final provider = res.provider;
    expect(error, isNull);
    expect(url, '$gotrueUrl/authorize?provider=google');
    expect(provider, 'google');
  });
}
