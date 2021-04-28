import 'package:hive/hive.dart';
import 'constants.dart';

import 'cross_platform/path.dart' as path;

class LocalStorage {
  late Box<String>? _box;
  bool _isBoxOpen = false;

  LocalStorage() {
    Hive.init(path.getBasePath());
  }

  Future _openBox() async {
    if (!_isBoxOpen) {
      _box = await Hive.openBox(Constants.localStorageBoxKey);

      _isBoxOpen = true;
    }
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
