import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/tourist_place.dart';
import '../database/database_helper.dart';
import 'tourist_place_detail_page.dart';

class TouristPlaceListPage extends StatefulWidget {
  final City city;
  const TouristPlaceListPage({Key? key, required this.city}) : super(key: key);

  @override
  State<TouristPlaceListPage> createState() => _TouristPlaceListPageState();
}

class _TouristPlaceListPageState extends State<TouristPlaceListPage> {
  late Future<List<TouristPlace>> _touristPlacesFuture;

  @override
  void initState() {
    super.initState();
    _loadTouristPlaces();
  }

  void _loadTouristPlaces() {
    _touristPlacesFuture = DatabaseHelper().getTouristPlacesByCity(
      widget.city.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wisata di ${widget.city.name}')),
      body: FutureBuilder<List<TouristPlace>>(
        future: _touristPlacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada tempat wisata di kota ini.'),
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
                        setState(() {
                          place.isFavorite = !place.isFavorite;
                        });
                        await DatabaseHelper().updateTouristPlace(place);
                        // Perbarui daftar favorit jika sedang berada di halaman favorit
                        // atau jika diperlukan di sini.
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
                        // Refresh the list when returning from detail page to reflect favorite changes
                        setState(() {
                          _loadTouristPlaces();
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
