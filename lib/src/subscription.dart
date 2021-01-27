import 'constants.dart';
import 'session.dart';

typedef Unsubscriber = void Function();
typedef Callback = void Function(AuthChangeEvent event, Session session);

class Subscription {
  String id;
  Callback callback;
  Unsubscriber unsubscribe;

  Subscription({this.id, this.callback, this.unsubscribe});
}
