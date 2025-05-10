```dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _user;
  Database? _database;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'task_manager.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            isAdmin INTEGER NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> register(String username, String email, String password) async {
    if (_database == null) await _initDatabase();
    final db = _database!;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = UserModel(
      id: id,
      username: username,
      email: email,
      password: password,
      isAdmin: false,
    );
    await db.insert('users', newUser.toMap());
    _user = newUser;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (_database == null) await _initDatabase();
    final db = _database!;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (users.isNotEmpty) {
      _user = UserModel.fromMap(users.first);
      notifyListeners();
    } else {
      throw Exception('Invalid email or password');
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
```