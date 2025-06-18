// main.dart
import 'package:flutter/material.dart';
import 'package:info_wisata_app/screens/home_screen.dart';
import 'package:info_wisata_app/utils/app_constants.dart'; // Untuk konstanta seperti UU dan PP

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Info Wisata App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      // Tambahkan rute jika ada banyak layar
      routes: {
        '/home': (context) => const HomeScreen(),
        // '/detail_wisata': (context) => const DetailWisataScreen(),
        // '/favorit': (context) => const FavoriteScreen(),
        // '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
