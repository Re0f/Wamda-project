import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'wamda.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // جدول التنبيهات
        await db.execute('''
          CREATE TABLE alerts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT NOT NULL,
            hour INTEGER NOT NULL,
            minute INTEGER NOT NULL,
            days_mask INTEGER NOT NULL,
            enabled INTEGER NOT NULL DEFAULT 1
          )
        ''');
      },
    );
  }
}
