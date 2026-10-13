import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'attendance.db');
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        national_code TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        role INTEGER NOT NULL,
        address TEXT,
        emergency_contact TEXT,
        emergency_phone TEXT,
        created_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        worker_id INTEGER NOT NULL,
        date INTEGER NOT NULL,
        status INTEGER NOT NULL,
        note TEXT,
        check_in_time INTEGER,
        check_out_time INTEGER,
        location TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (worker_id) REFERENCES workers (id) ON DELETE CASCADE,
        UNIQUE(worker_id, date)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_attendance_date ON attendance_records(date)
    ''');
    await db.execute('''
      CREATE INDEX idx_attendance_worker ON attendance_records(worker_id)
    ''');
  }

  Future<int> insertWorker(Worker worker) async {
    final db = await database;
    return await db.insert('workers', worker.toMap());
  }

  Future<List<Worker>> getAllWorkers({bool activeOnly = true}) async {
    final db = await database;
    final maps = await db.query(
      'workers',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'name ASC',
    );
    return maps.map((e) => Worker.fromMap(e)).toList();
  }

  Future<Worker?> getWorkerById(int id) async {
    final db = await database;
    final maps = await db.query('workers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Worker.fromMap(maps.first);
  }

  Future<int> updateWorker(Worker worker) async {
    final db = await database;
    return await db.update(
      'workers',
      worker.toMap(),
      where: 'id = ?',
      whereArgs: [worker.id],
    );
  }

  Future<int> deleteWorker(int id) async {
    final db = await database;
    return await db.delete('workers', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertAttendance(AttendanceRecord record) async {
    final db = await database;
    final dayStart = DateTime(record.date.year, record.date.month, record.date.day);
    final nextDay = dayStart.add(const Duration(days: 1));
    final normalized = record.copyWith(date: dayStart);

    return db.transaction((txn) async {
      final existing = await txn.query(
        'attendance_records',
        columns: ['id'],
        where: 'worker_id = ? AND date >= ? AND date < ?',
        whereArgs: [
          record.workerId,
          dayStart.millisecondsSinceEpoch,
          nextDay.millisecondsSinceEpoch,
        ],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        final id = existing.first['id'] as int;
        return txn.update(
          'attendance_records',
          normalized.copyWith(id: id).toMap(),
          where: 'id = ?',
          whereArgs: [id],
        );
      }

      return txn.insert('attendance_records', normalized.toMap());
    });
  }

  Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final maps = await db.query(
      'attendance_records',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return maps.map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceByWorker(int workerId) async {
    final db = await database;
    final maps = await db.query(
      'attendance_records',
      where: 'worker_id = ?',
      whereArgs: [workerId],
      orderBy: 'date DESC',
    );
    return maps.map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceRange(
    DateTime start,
    DateTime end, {
    int? workerId,
  }) async {
    final db = await database;
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endExclusive = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
    String where = 'date >= ? AND date < ?';
    List<dynamic> args = [startOfDay.millisecondsSinceEpoch, endExclusive.millisecondsSinceEpoch];
    if (workerId != null) {
      where += ' AND worker_id = ?';
      args.add(workerId);
    }
    final maps = await db.query(
      'attendance_records',
      where: where,
      whereArgs: args,
      orderBy: 'date DESC',
    );
    return maps.map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  Future<AttendanceRecord?> getAttendanceByWorkerAndDate(int workerId, DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final maps = await db.query(
      'attendance_records',
      where: 'worker_id = ? AND date >= ? AND date < ?',
      whereArgs: [workerId, startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    if (maps.isEmpty) return null;
    return AttendanceRecord.fromMap(maps.first);
  }

  Future<int> updateAttendance(AttendanceRecord record) async {
    final db = await database;
    return await db.update(
      'attendance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete('attendance_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getAttendanceStats(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM attendance_records
      WHERE date >= ? AND date < ?
      GROUP BY status
    ''', [
      DateTime(start.year, start.month, start.day).millisecondsSinceEpoch,
      DateTime(end.year, end.month, end.day).add(const Duration(days: 1)).millisecondsSinceEpoch,
    ]);

    final stats = <String, int>{};
    for (var map in maps) {
      final status = AttendanceStatus.values[map['status'] as int];
      stats[status.label] = map['count'] as int;
    }
    return stats;
  }

  Future<List<Map<String, dynamic>>> getWorkerAttendanceSummary(DateTime start, DateTime end) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT w.id, w.name, w.national_code, w.role,
             COUNT(a.id) as total_days,
             SUM(CASE WHEN a.status = 0 THEN 1 ELSE 0 END) as present_count,
             SUM(CASE WHEN a.status = 1 THEN 1 ELSE 0 END) as absent_count,
             SUM(CASE WHEN a.status = 2 THEN 1 ELSE 0 END) as late_count,
             SUM(CASE WHEN a.status = 3 THEN 1 ELSE 0 END) as leave_count,
             SUM(CASE WHEN a.status = 4 THEN 1 ELSE 0 END) as mission_count
      FROM workers w
      LEFT JOIN attendance_records a ON w.id = a.worker_id
        AND a.date >= ? AND a.date < ?
      WHERE w.is_active = 1
      GROUP BY w.id
      ORDER BY w.name
    ''', [
      DateTime(start.year, start.month, start.day).millisecondsSinceEpoch,
      DateTime(end.year, end.month, end.day).add(const Duration(days: 1)).millisecondsSinceEpoch,
    ]);
  }

  Future<void> init() async {
    await database;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}