// lib/screens/home_screen.dart (bagian yang dimodifikasi)
import 'package:flutter/material.dart';
import 'package:info_wisata_app/widgets/wisata_list_view.dart';
import 'package:info_wisata_app/services/network_service.dart';
import 'package:info_wisata_app/widgets/search_bar_widget.dart';
import 'package:info_wisata_app/utils/device_info_util.dart';
import 'package:info_wisata_app/utils/app_constants.dart';
import 'package:info_wisata_app/services/database_helper.dart'; // Import DatabaseHelper
import 'package:info_wisata_app/models/wisata_model.dart'; // Import Wisata model

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  String _deviceInfo = 'Memuat informasi perangkat...';
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Inisialisasi DatabaseHelper
  List<Wisata> _wisataList = []; // Daftar wisata yang akan ditampilkan

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
    _loadDeviceInfo();
    _loadAllWisata(); // Muat semua data wisata saat aplikasi dimulai
    _insertInitialData(); // Contoh: masukkan data awal (hapus ini di produksi)
  }

  // Fungsi untuk memasukkan data awal (hanya untuk demonstrasi)
  Future<void> _insertInitialData() async {
    // Cek apakah database sudah ada isinya atau belum untuk menghindari duplikasi
    final existingWisata = await _dbHelper.getAllWisata();
    if (existingWisata.isEmpty) {
      await _dbHelper.insertWisata(Wisata(
        nama: 'Monumen Nasional',
        deskripsi: 'Landmark ikonik Jakarta, Indonesia. Terletak di pusat kota.',
        kota: 'Jakarta',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Monas_from_East.jpg/300px-Monas_from_East.jpg',
        isFavorite: 0,
      ));
      await _dbHelper.insertWisata(Wisata(
        nama: 'Candi Borobudur',
        deskripsi: 'Kuil Buddha terbesar di dunia, terletak di Magelang.',
        kota: 'Magelang',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Borobudur_Sunrise_2017.jpg/300px-Borobudur_Sunrise_2017.jpg',
        isFavorite: 0,
      ));
      await _dbHelper.insertWisata(Wisata(
        nama: 'Pantai Kuta',
        deskripsi: 'Pantai terkenal dengan matahari terbenamnya di Bali.',
        kota: 'Denpasar', // Atau Badung
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Kuta_Beach.jpg/300px-Kuta_Beach.jpg',
        isFavorite: 0,
      ));
      // Muat ulang daftar setelah menambahkan data
      _loadAllWisata();
    }
  }

  Future<void> _checkNetworkStatus() async {
    final connected = await NetworkService.checkConnectivity();
    setState(() {
      _isConnected = connected;
    });
  }

  Future<void> _loadDeviceInfo() async {
    final info = await DeviceInfoUtil.getDeviceInfo();
    setState(() {
      _deviceInfo = info;
    });
  }

  Future<void> _loadAllWisata() async {
    final wisata = await _dbHelper.getAllWisata();
    setState(() {
      _wisataList = wisata;
    });
  }

  Future<void> _searchWisata(String query) async {
    if (query.isEmpty) {
      _loadAllWisata(); // Jika query kosong, tampilkan semua
    } else {
      final result = await _dbHelper.searchWisataByKota(query);
      setState(() {
        _wisataList = result;
      });
    }
  }

  Future<void> _toggleFavorite(Wisata wisata) async {
    wisata.isFavorite = wisata.isFavorite == 1 ? 0 : 1;
    await _dbHelper.updateWisata(wisata);
    _loadAllWisata(); // Muat ulang daftar untuk refresh UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${wisata.nama} ${wisata.isFavorite == 1 ? 'ditambahkan ke' : 'dihapus dari'} favorit!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Wisata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Navigasi ke halaman favorit
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteScreen(dbHelper: _dbHelper)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigasi ke halaman pengaturan
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBarWidget(
              onSearch: _searchWisata,
            ),
          ),
          _isConnected
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Tidak ada koneksi internet', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
          Expanded(
            child: WisataListView(
              wisataList: _wisataList,
              onToggleFavorite: _toggleFavorite, // Teruskan callback
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Info Perangkat: $_deviceInfo',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Aplikasi ini mematuhi ${AppConstants.uu_11_2008} dan ${AppConstants.pp_82_2012}.',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}