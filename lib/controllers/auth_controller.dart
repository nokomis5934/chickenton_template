// lib/controllers/auth_controller.dart
import 'package:template/utills/secure_storage_helper.dart';

class AuthController {
  // 마스터 키가 설정되어 있는지 확인
  Future<bool> isMasterKeySet() async {
    final key = await SecureStorageHelper.getMasterKey();
    return key != null && key.isNotEmpty;
  }

  // 입력된 키와 저장된 키를 비교하여 인증
  Future<bool> authenticate(String inputKey) async {
    final storedKey = await SecureStorageHelper.getMasterKey();
    // 주의: 실제 앱에서는 입력된 키를 해시하여 저장된 해시값과 비교해야 합니다.
    // 이 예제에서는 간단히 문자열 비교를 합니다.
    return storedKey == inputKey;
  }

  // 새로운 마스터 키 설정
  Future<void> setMasterKey(String newKey) async {
    await SecureStorageHelper.saveMasterKey(newKey);
  }
}
