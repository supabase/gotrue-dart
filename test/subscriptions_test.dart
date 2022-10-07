// import 'package:gotrue/gotrue.dart';
// import 'package:test/test.dart';

// void main() {
//   const gotrueUrl = 'http://localhost:9998';
//   const annonToken = '';

//   late GoTrueClient client;
//   late AuthSubscriptionResponse res;
//   late AuthSubscription subscription;

//   setUp(() {
//     client = GoTrueClient(
//       url: gotrueUrl,
//       headers: {
//         'Authorization': 'Bearer $annonToken',
//         'apikey': annonToken,
//       },
//     );

//     res = client.onAuthStateChange((event, session) {});
//     subscription = res.data!;
//   });

//   test('Subscribe a listener', () async {
//     expect(client._stateChangeEmitters.keys.length, 1);
//   });

//   test('Unsubscribe a listener', () async {
//     subscription.unsubscribe();
//     expect(client._stateChangeEmitters.keys.length, 0);
//   });
// }
