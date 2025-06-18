import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart'; // Import model User yang baru
import '../models/city.dart';
import '../models/tourist_place.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tourism_database.db");

    // Check if the database already exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // If not, copy from assets
      print("Creating new copy from assets");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Pastikan path ke database di assets benar
      ByteData data = await rootBundle.load(join("assets", "database", "tourism_database.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    // Perhatikan: Jika Anda mengubah skema database (misal: menambah tabel 'users'),
    // Anda harus menaikkan 'version' di sini dan menyediakan callback 'onCreate'
    // atau 'onUpgrade' untuk menangani perubahan skema.
    // Untuk pengembangan, cara termudah melihat perubahan skema adalah uninstall & install ulang app.
    return await openDatabase(
      path,
      version: 1, // Jika Anda menambahkan tabel baru, Anda mungkin perlu meningkatkan versi ini
      // Misalnya, jika ini adalah versi 2 dan Anda ingin membuat tabel 'users' jika belum ada:
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     await db.execute('''
      //       CREATE TABLE users (
      //           id INTEGER PRIMARY KEY AUTOINCREMENT,
      //           username TEXT NOT NULL UNIQUE,
      //           password TEXT NOT NULL
      //       );
      //     ''');
      //   }
      // },
    );
  }

  // Cek apakah database sudah ada di path aplikasi
  Future<bool> databaseExists(String path) async {
    return File(path).exists();
  }

  // --- Operasi Database untuk Kota ---
  Future<List<City>> getCities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cities');
    return List.generate(maps.length, (i) {
      return City.fromMap(maps[i]);
    });
  }

  Future<City?> getCityById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cities',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return City.fromMap(maps.first);
    }
    return null;
  }

  // --- Operasi Database untuk Tempat Wisata ---
  Future<List<TouristPlace>> getTouristPlacesByCity(int cityId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tourist_places',
      where: 'city_id = ?',
      whereArgs: [cityId],
    );
    return List.generate(maps.length, (i) {
      return TouristPlace.fromMap(maps[i]);
    });
  }

  Future<TouristPlace?> getTouristPlaceById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tourist_places',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TouristPlace.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTouristPlace(TouristPlace place) async {
    final db = await database;
    return await db.update(
      'tourist_places',
      place.toMap(),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  Future<List<TouristPlace>> getFavoriteTouristPlaces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tourist_places',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return TouristPlace.fromMap(maps[i]);
    });
  }

  // --- Operasi Database untuk User ---
  // Mendaftarkan user baru
  Future<int> insertUser(User user) async {
    final db = await database;
    try {
      // ConflictAlgorithm.replace akan mengganti jika ada konflik PRIMARY KEY (misal: jika id sudah ada)
      // Namun, untuk username UNIQUE, ini akan melempar Unique constraint failed jika username duplikat.
      return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      print('Error inserting user: $e');
      // Anda bisa menangani error duplikasi username di sini
      // Misalnya, jika ingin mengembalikan -1 untuk duplikasi username
      if (e.toString().contains('UNIQUE constraint failed')) {
        print('Username already exists.');
        return -2; // Kode khusus untuk duplikasi username
      }
      return -1; // Mengindikasikan kegagalan umum
    }
  }

  // Mencari user berdasarkan username (untuk verifikasi apakah username sudah ada saat daftar)
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Fungsi untuk login (memeriksa username dan password)
  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?', // PERHATIAN: Password disimpan plain text di contoh ini!
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}