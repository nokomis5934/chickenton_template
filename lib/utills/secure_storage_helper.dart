// lib/utils/secure_storage_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();
  static const _masterKey = 'master_key';

  // 마스터 키를 안전하게 저장
  static Future<void> saveMasterKey(String key) async {
    await _storage.write(key: _masterKey, value: key);
  }

  // 저장된 마스터 키를 가져옴
  static Future<String?> getMasterKey() async {
    return await _storage.read(key: _masterKey);
  }
}
