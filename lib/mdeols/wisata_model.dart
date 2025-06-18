// lib/models/wisata_model.dart
class Wisata {
  int? id; // ID akan di-generate otomatis oleh database
  final String nama;
  final String deskripsi;
  final String kota;
  final String imageUrl; // Contoh: tambahkan imageUrl
  int isFavorite; // 0 untuk false, 1 untuk true

  Wisata({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.kota,
    required this.imageUrl,
    this.isFavorite = 0, // Default tidak favorit
  });

  // Konversi Wisata ke Map. Berguna saat menyimpan ke database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'kota': kota,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  // Konversi Map ke objek Wisata. Berguna saat mengambil dari database.
  factory Wisata.fromMap(Map<String, dynamic> map) {
    return Wisata(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      kota: map['kota'],
      imageUrl: map['imageUrl'],
      isFavorite: map['isFavorite'],
    );
  }
}
