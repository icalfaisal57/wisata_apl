// lib/screens/favorite_screen.dart
import 'package:flutter/material.dart';
import 'package:info_wisata_app/models/wisata_model.dart';
import 'package:info_wisata_app/services/database_helper.dart'; // Import DatabaseHelper

class FavoriteScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const FavoriteScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Wisata> _favoriteWisataList = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteWisata();
  }

  Future<void> _loadFavoriteWisata() async {
    final favorites = await widget.dbHelper.getFavoriteWisata();
    setState(() {
      _favoriteWisataList = favorites;
    });
  }

  Future<void> _toggleFavorite(Wisata wisata) async {
    wisata.isFavorite = wisata.isFavorite == 1 ? 0 : 1;
    await widget.dbHelper.updateWisata(wisata);
    _loadFavoriteWisata(); // Muat ulang daftar favorit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${wisata.nama} ${wisata.isFavorite == 1 ? 'ditambahkan ke' : 'dihapus dari'} favorit!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tempat Favorit')),
      body:
          _favoriteWisataList.isEmpty
              ? const Center(child: Text('Belum ada tempat wisata favorit.'))
              : ListView.builder(
                itemCount: _favoriteWisataList.length,
                itemBuilder: (context, index) {
                  final wisata = _favoriteWisataList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(wisata.imageUrl),
                        child:
                            wisata.imageUrl.isEmpty
                                ? const Icon(Icons.image)
                                : null,
                      ),
                      title: Text(wisata.nama),
                      subtitle: Text('Kota: ${wisata.kota}'),
                      trailing: IconButton(
                        icon: Icon(
                          wisata.isFavorite == 1
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: wisata.isFavorite == 1 ? Colors.red : null,
                        ),
                        onPressed: () {
                          _toggleFavorite(wisata);
                        },
                      ),
                      onTap: () {
                        // Navigasi ke halaman detail wisata jika diperlukan
                      },
                    ),
                  );
                },
              ),
    );
  }
}
