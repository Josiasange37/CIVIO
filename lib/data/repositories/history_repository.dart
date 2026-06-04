import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HistoryRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('civio_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        procedure_id TEXT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT
      )
    ''');
  }

  Future<int> addToHistory(String title, String? procedureId, String type, String? data) async {
    final db = await database;
    return await db.insert('history', {
      'title': title,
      'procedure_id': procedureId,
      'date': DateTime.now().toIso8601String(),
      'type': type,
      'data': data,
    });
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('history', orderBy: 'date DESC');
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }
}
