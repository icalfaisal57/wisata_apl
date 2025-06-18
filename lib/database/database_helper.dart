import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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

      ByteData data = await rootBundle.load(join("assets", "database", "tourism_database.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    return await openDatabase(path, version: 1);
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
}