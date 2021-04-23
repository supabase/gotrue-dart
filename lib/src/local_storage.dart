import 'package:sembast/sembast.dart';

import 'constants.dart';
import 'cross_platform/path.dart' as path;
import 'cross_platform/sembast.dart';

class LocalStorage {
  bool _isPersistSessionDbOpen = false;
  late final Database _persistSessionDb;
  late final StoreRef _store;

  LocalStorage();

  Future _openPersistSessionDb() async {
    if (!_isPersistSessionDbOpen) {
      _persistSessionDb = await getDatabaseFactory().openDatabase(
          '${path.getBasePath()}/${Constants.persistSessionDbFileName}');

      _store = StoreRef.main();

      _isPersistSessionDbOpen = true;
    }
  }

  Future<String> read(String key) async {
    await _openPersistSessionDb();

    final value = await _store.record(key).get(_persistSessionDb);

    return value as String;
  }

  Future write(String key, String value) async {
    await _openPersistSessionDb();

    await _store.record(key).put(_persistSessionDb, value);
  }

  Future delete(String key) async {
    await _openPersistSessionDb();

    await _store.record(key).delete(_persistSessionDb);
  }
}
