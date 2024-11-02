import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  final _box = GetStorage();

  // Anahtar sabitleri
  static const String _keyUserId = 'user_id';
  static const String _keyAppVersion = 'app_version';

  // Kullanıcı ID'si için metodlar
  Future<void> saveUserId(String uid) async {
    await _box.write(_keyUserId, uid);
  }

  String? getUserId() {
    return _box.read<String>(_keyUserId);
  }

  Future<void> removeUserId() async {
    await _box.remove(_keyUserId);
  }

  // Uygulama versiyonu için metodlar
  Future<void> saveAppVersion(String version) async {
    await _box.write(_keyAppVersion, version);
  }

  String? getAppVersion() {
    return _box.read<String>(_keyAppVersion);
  }

  // Tüm verileri temizleme
  Future<void> clearAll() async {
    await _box.erase();
  }
}
