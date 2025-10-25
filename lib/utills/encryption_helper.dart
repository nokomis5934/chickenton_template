// lib/utils/encryption_helper.dart
import 'package:encrypt/encrypt.dart';

// 보안 학습 목적의 단순 예제 Key/IV.
// 실제 앱에서는 KeyStore/Keychain 등 안전한 저장소에 보관해야 함.
final key = Key.fromLength(32);
final iv = IV.fromLength(16);
final encrypter = Encrypter(AES(key));

class EncryptionHelper {
  static String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // 복호화 실패 시 (예: Key 불일치 등)
      return '복호화 오류';
    }
  }
}
