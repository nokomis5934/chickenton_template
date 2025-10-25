// lib/controllers/database_controller.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';

class DatabaseController {
  static final DatabaseController instance = DatabaseController._init();
  static Database? _database;

  DatabaseController._init();

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

  Future<PasswordEntry> createEntry(PasswordEntry entry) async {
    final db = await instance.database;
    final id = await db.insert('passwords', entry.toMap());
    return entry.copyWith(id: id);
  }

  Future<List<PasswordEntry>> readAllEntries() async {
    final db = await instance.database;
    final result = await db.query('passwords', orderBy: 'createdAt DESC');
    return result.map((json) => PasswordEntry.fromMap(json)).toList();
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}
