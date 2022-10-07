import 'package:gotrue/src/constants.dart';
import 'package:gotrue/src/types/session.dart';

typedef Unsubscriber = void Function();
typedef Callback = void Function(AuthChangeEvent event, Session? session);

class AuthSubscription {
  final String id;
  final Callback callback;
  final Unsubscriber unsubscribe;

  const AuthSubscription({
    required this.id,
    required this.callback,
    required this.unsubscribe,
  });
}
