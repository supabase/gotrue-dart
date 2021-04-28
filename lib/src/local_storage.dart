import 'package:hive/hive.dart';
import 'constants.dart';

import 'cross_platform/path.dart' as path;

class LocalStorage {
  late Box<String>? _box;

  LocalStorage() {
    Hive.init(path.getBasePath());

    // _box = Hive.openBox(Constants.localStorageBoxKey);
  }

  Future _openBox() async {
    _box = await Hive.openBox(Constants.localStorageBoxKey);
  }

  Future<String?> read(String key) async {
    await _openBox();

    final String? value = _box!.get(key);

    return value;
  }

  Future<void> write(String key, String value) async {
    await _openBox();

    _box!.put(key, value);
  }

  Future<void> delete(String key) async {
    await _openBox();

    _box!.delete(key);
  }
}
