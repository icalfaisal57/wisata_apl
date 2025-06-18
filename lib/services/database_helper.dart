// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wisata_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'info_wisata_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade:
          _onUpgrade, // Tambahkan onUpgrade untuk update schema di masa depan
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wisata(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        kota TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
    // Anda bisa menambahkan data awal di sini jika diperlukan
    // Misalnya:
    // await db.insert('wisata', Wisata(
    //   nama: 'Monumen Nasional',
    //   deskripsi: 'Landmark ikonik Jakarta.',
    //   kota: 'Jakarta',
    //   imageUrl: 'https://example.com/monas.jpg',
    // ).toMap());
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Logika untuk migrasi database jika versi berubah
    // Contoh: Jika Anda menambahkan kolom baru di versi 2
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE wisata ADD COLUMN newColumn TEXT");
    // }
  }

  // --- Operasi CRUD untuk Wisata ---

  Future<int> insertWisata(Wisata wisata) async {
    final db = await database;
    return await db.insert(
      'wisata',
      wisata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Wisata>> getAllWisata() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wisata');
    return List.generate(maps.length, (i) {
      return Wisata.fromMap(maps[i]);
    });
  }

  Future<List<Wisata>> searchWisataByKota(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wisata',
      where: 'kota LIKE ? OR nama LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Wisata.fromMap(maps[i]);
    });
  }

  Future<List<Wisata>> getFavoriteWisata() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wisata',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Wisata.fromMap(maps[i]);
    });
  }

  Future<int> updateWisata(Wisata wisata) async {
    final db = await database;
    return await db.update(
      'wisata',
      wisata.toMap(),
      where: 'id = ?',
      whereArgs: [wisata.id],
    );
  }

  Future<int> deleteWisata(int id) async {
    final db = await database;
    return await db.delete('wisata', where: 'id = ?', whereArgs: [id]);
  }
}
