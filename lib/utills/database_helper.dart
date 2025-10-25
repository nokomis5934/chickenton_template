// lib/utils/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:template/models/password_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('passwords.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE passwords (
        id $idType,
        siteName $textType,
        encryptedPassword $textType,
        createdAt $textType
      )
    ''');
  }

  // CREATE (추가)
  Future<PasswordEntry> create(PasswordEntry entry) async {
    final db = await instance.database;
    final id = await db.insert('passwords', entry.toMap());
    // 삽입된 ID와 함께 새로운 객체 반환
    return entry.copyWith(id: id);
  }

  // READ ALL (전체 조회)
  Future<List<PasswordEntry>> readAllEntries() async {
    final db = await instance.database;
    final result = await db.query('passwords', orderBy: 'createdAt DESC');

    return result.map((json) => PasswordEntry.fromMap(json)).toList();
  }

  // DELETE (삭제)
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}
