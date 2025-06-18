import 'package:flutter/material.dart';
import '../models/tourist_place.dart';
import '../database/database_helper.dart';
import 'tourist_place_detail_page.dart'; // Untuk navigasi ke detail dari favorit

class FavoritePlacesPage extends StatefulWidget {
  const FavoritePlacesPage({Key? key}) : super(key: key);

  @override
  State<FavoritePlacesPage> createState() => _FavoritePlacesPageState();
}

class _FavoritePlacesPageState extends State<FavoritePlacesPage> {
  late Future<List<TouristPlace>> _favoritePlacesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavoritePlaces();
  }

  // Fungsi untuk memuat ulang daftar favorit
  void _loadFavoritePlaces() {
    _favoritePlacesFuture = DatabaseHelper().getFavoriteTouristPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tempat Favorit Saya')),
      body: FutureBuilder<List<TouristPlace>>(
        future: _favoritePlacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Anda belum menambahkan tempat wisata ke favorit.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final place = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListTile(
                    leading:
                        place.imageUrl.isNotEmpty
                            ? Image.asset(
                              'assets/images/${place.imageUrl}', // Sesuaikan dengan path gambar Anda
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                            : null,
                    title: Text(place.name),
                    subtitle: Text(
                      place.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        place.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: place.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () async {
                        // Toggle status favorit
                        setState(() {
                          place.isFavorite = !place.isFavorite;
                        });
                        await DatabaseHelper().updateTouristPlace(place);
                        // Muat ulang daftar favorit setelah perubahan
                        _loadFavoritePlaces();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TouristPlaceDetailPage(place: place),
                        ),
                      ).then((_) {
                        // Refresh daftar favorit saat kembali dari halaman detail
                        setState(() {
                          _loadFavoritePlaces();
                        });
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
