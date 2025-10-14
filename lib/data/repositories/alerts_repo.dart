import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/alert.dart';

class AlertsRepo {
  AlertsRepo._();
  static final AlertsRepo instance = AlertsRepo._();

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> insert(Alert a) async {
    final db = await _db;
    return db.insert('alerts', a.toMap()..remove('id'));
  }

  Future<List<Alert>> getAll() async {
    final db = await _db;
    final rows = await db.query('alerts', orderBy: 'hour, minute');
    return rows.map(Alert.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('alerts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Alert a) async {
    final db = await _db;
    return db.update('alerts', a.toMap(),
        where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> toggleEnabled(int id, bool enabled) async {
    final db = await _db;
    return db.update('alerts', {'enabled': enabled ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
