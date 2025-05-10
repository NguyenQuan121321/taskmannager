```dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class TaskService {
  Database? _database;

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'task_manager.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            priority INTEGER NOT NULL,
            dueDate TEXT,
            assignedTo TEXT NOT NULL,
            createdBy TEXT NOT NULL,
            category TEXT,
            completed INTEGER NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> createTask(TaskModel task) async {
    if (_database == null) await _initDatabase();
    final db = _database!;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    if (_database == null) await _initDatabase();
    final db = _database!;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String taskId) async {
    if (_database == null) await _initDatabase();
    final db = _database!;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<List<TaskModel>> getTasks(String userId, bool isAdmin) async {
    if (_database == null) await _initDatabase();
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: isAdmin ? null : 'assignedTo = ?',
      whereArgs: isAdmin ? null : [userId],
    );
    return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
  }

  Future<List<TaskModel>> searchTasks(String userId, bool isAdmin, String query, String? status, String? category) async {
    if (_database == null) await _initDatabase();
    final db = _database!;
    List<Map<String, dynamic>> maps = await db.query('tasks');
    if (!isAdmin) {
      maps = maps.where((map) => map['assignedTo'] == userId).toList();
    }
    if (status != null) {
      maps = maps.where((map) => map['status'] == status).toList();
    }
    if (category != null) {
      maps = maps.where((map) => map['category'] == category).toList();
    }
    return maps
        .where((map) => map['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
            map['description'].toString().toLowerCase().contains(query.toLowerCase()))
        .map((map) => TaskModel.fromMap(map))
        .toList();
  }
}
```