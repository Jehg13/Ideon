import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasesPath, 'ideon.db'),
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE captures (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            type TEXT NOT NULL,
            project TEXT NOT NULL,
            priority TEXT NOT NULL,
            tags TEXT NOT NULL,
            created_at TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await database.execute('''
          CREATE TABLE projects (
            name TEXT PRIMARY KEY,
            description TEXT NOT NULL,
            technologies TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<Map<String, Object?>>> getCaptures() async {
    final database = await this.database;
    return database.query('captures', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, Object?>>> getProjects() async {
    final database = await this.database;
    return database.query('projects', orderBy: 'created_at ASC');
  }

  Future<void> replaceAll({
    required List<Map<String, Object?>> captures,
    required List<Map<String, Object?>> projects,
  }) async {
    final database = await this.database;
    await database.transaction((transaction) async {
      await transaction.delete('captures');
      await transaction.delete('projects');
      for (final capture in captures) {
        await transaction.insert('captures', capture);
      }
      for (final project in projects) {
        await transaction.insert('projects', project);
      }
    });
  }

  Future<void> upsertCapture(Map<String, Object?> capture) async {
    final database = await this.database;
    await database.insert(
      'captures',
      capture,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCapture(String id) async {
    final database = await this.database;
    await database.delete('captures', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertProject(Map<String, Object?> project) async {
    final database = await this.database;
    await database.insert(
      'projects',
      project,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
