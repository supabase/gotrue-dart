import 'package:sembast/sembast.dart';

import 'constants.dart';
import 'cross_platform/path.dart' as path;
import 'cross_platform/sembast.dart';

class LocalStorage {
  bool _isOpen = false;
  late final Database _localDb;
  late final StoreRef _store;

  LocalStorage();

  Future _openDb() async {
    if (!_isOpen) {
      _localDb = await getDatabaseFactory().openDatabase(
          '${path.getBasePath()}/${Constants.persistSessionDbFileName}');

      _store = StoreRef.main();

      _isOpen = true;
    }
  }

  Future<String> read(String key) async {
    await _openDb();

    final value = await _store.record(key).get(_localDb);

    return value as String;
  }

  Future write(String key, String value) async {
    await _openDb();

    await _store.record(key).put(_localDb, value);
  }

  Future delete(String key) async {
    await _openDb();

    await _store.record(key).delete(_localDb);
  }
}
