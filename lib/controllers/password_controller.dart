// lib/controllers/password_controller.dart
import 'dart:math';
import 'package:template/controllers/database_controller.dart';
import 'package:template/models/password_entry.dart';
import 'package:template/utills/encryption_helper.dart';
import 'package:intl/intl.dart';

class PasswordController {
  final DatabaseController _dbController = DatabaseController.instance;

  // 1. 비밀번호 생성 로직
  String generatePassword({
    required int length,
    required bool useUppercase,
    required bool useNumbers,
    required bool useSpecial,
  }) {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_-+=<>?';

    String chars = lower;
    if (useUppercase) chars += upper;
    if (useNumbers) chars += numbers;
    if (useSpecial) chars += special;

    if (chars.isEmpty) return '';

    // 안전한 난수 생성을 위해 Random.secure() 사용
    final random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // 2. 비밀번호 저장 로직
  Future<void> savePassword(String siteName, String plainPassword) async {
    if (siteName.isEmpty || plainPassword.isEmpty) return;

    // 저장 전 암호화
    final encrypted = EncryptionHelper.encrypt(plainPassword);

    final entry = PasswordEntry(
      siteName: siteName,
      encryptedPassword: encrypted,
      createdAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );

    await _dbController.createEntry(entry);
  }

  // 3. 비밀번호 목록 조회 로직
  Future<List<PasswordEntry>> loadPasswords() async {
    return _dbController.readAllEntries();
  }

  // 4. 비밀번호 삭제 로직
  Future<void> deletePassword(int id) async {
    await _dbController.deleteEntry(id);
  }

  // 5. 복호화 (UI 표시용)
  String decryptPassword(String encryptedText) {
    return EncryptionHelper.decrypt(encryptedText);
  }
}
