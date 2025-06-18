import 'package:flutter/material.dart';
import '../models/tourist_place.dart';
import '../database/database_helper.dart';

class TouristPlaceDetailPage extends StatefulWidget {
  final TouristPlace place;
  const TouristPlaceDetailPage({Key? key, required this.place})
    : super(key: key);

  @override
  State<TouristPlaceDetailPage> createState() => _TouristPlaceDetailPageState();
}

class _TouristPlaceDetailPageState extends State<TouristPlaceDetailPage> {
  late TouristPlace _currentPlace;

  @override
  void initState() {
    super.initState();
    _currentPlace = widget.place;
  }

  void _toggleFavorite() async {
    setState(() {
      _currentPlace.isFavorite = !_currentPlace.isFavorite;
    });
    await DatabaseHelper().updateTouristPlace(_currentPlace);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentPlace.isFavorite
              ? 'Ditambahkan ke favorit'
              : 'Dihapus dari favorit',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPlace.name),
        actions: [
          IconButton(
            icon: Icon(
              _currentPlace.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _currentPlace.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _currentPlace.imageUrl.isNotEmpty
                ? Image.asset(
                  'assets/images/${_currentPlace.imageUrl}', // Sesuaikan dengan path gambar Anda
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                )
                : Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: Text('No Image')),
                ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPlace.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentPlace.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  // Anda bisa menambahkan informasi lain di sini, seperti alamat, jam buka, dll.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
