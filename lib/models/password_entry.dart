// lib/models/password_entry.dart

class PasswordEntry {
  final int? id;
  final String siteName;
  final String encryptedPassword;
  final String createdAt;

  PasswordEntry({
    this.id,
    required this.siteName,
    required this.encryptedPassword,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'siteName': siteName,
      'encryptedPassword': encryptedPassword,
      'createdAt': createdAt,
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] as int,
      siteName: map['siteName'] as String,
      encryptedPassword: map['encryptedPassword'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  // DB 업데이트를 위해 ID 유지를 위한 헬퍼 함수
  PasswordEntry copyWith({
    int? id,
    String? siteName,
    String? encryptedPassword,
    String? createdAt,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      siteName: siteName ?? this.siteName,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
