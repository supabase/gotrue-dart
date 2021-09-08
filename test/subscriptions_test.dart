import 'package:gotrue/gotrue.dart';
import 'package:gotrue/src/gotrue_response.dart';
import 'package:gotrue/src/subscription.dart';
import 'package:test/test.dart';

void main() {
  const gotrueUrl = 'http://localhost:9999';
  const annonToken = '';

  late GoTrueClient client;
  late GotrueSubscription res;
  late Subscription subscription;

  setUp(() {
    client = GoTrueClient(
      url: gotrueUrl,
      headers: {
        'Authorization': 'Bearer $annonToken',
        'apikey': annonToken,
      },
    );

    res = client.onAuthStateChange((event, session) {});
    subscription = res.data!;
  });

  test('Subscribe a listener', () async {
    expect(client.stateChangeEmitters.keys.length, 1);
  });

  test('Unsubscribe a listener', () async {
    subscription.unsubscribe();
    expect(client.stateChangeEmitters.keys.length, 0);
  });
}
