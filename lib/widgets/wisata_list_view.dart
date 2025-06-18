// lib/widgets/wisata_list_view.dart
import 'package:flutter/material.dart';
import 'package:info_wisata_app/models/wisata_model.dart';

class WisataListView extends StatelessWidget {
  final List<Wisata> wisataList;
  final Function(Wisata) onToggleFavorite; // Callback untuk favorit

  const WisataListView({
    Key? key,
    required this.wisataList,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wisataList.isEmpty) {
      return const Center(
        child: Text('Tidak ada tempat wisata yang ditemukan.'),
      );
    }
    return ListView.builder(
      itemCount: wisataList.length,
      itemBuilder: (context, index) {
        final wisata = wisataList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                wisata.imageUrl,
              ), // Tampilkan gambar
              child: wisata.imageUrl.isEmpty ? const Icon(Icons.image) : null,
            ),
            title: Text(wisata.nama),
            subtitle: Text(
              'Kota: ${wisata.kota}\n${wisata.deskripsi.substring(0, wisata.deskripsi.length > 50 ? 50 : wisata.deskripsi.length)}...',
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: Icon(
                wisata.isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
                color: wisata.isFavorite == 1 ? Colors.red : null,
              ),
              onPressed: () {
                onToggleFavorite(wisata); // Panggil callback
              },
            ),
            onTap: () {
              // Navigasi ke halaman detail wisata
              // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailWisataScreen(wisata: wisata)));
            },
          ),
        );
      },
    );
  }
}
