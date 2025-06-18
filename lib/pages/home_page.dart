import 'package:flutter/material.dart';
import 'city_selection_page.dart';
import 'favorite_places_page.dart'; // Import halaman favorit yang baru

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Wisata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Navigasi ke halaman daftar tempat favorit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritePlacesPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat datang di aplikasi Info Wisata!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CitySelectionPage(),
                  ),
                );
              },
              child: const Text('Pilih Kota'),
            ),
          ],
        ),
      ),
    );
  }
}
