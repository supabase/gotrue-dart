import 'package:sembast/sembast.dart';

DatabaseFactory getDatabaseFactory() => _stub('getDatabaseFactory');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
