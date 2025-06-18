import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemChrome
import 'pages/home_page.dart';
import 'widgets/connection_status_widget.dart'; // Import widget koneksi

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opsional: Untuk memastikan orientasi hanya portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Info Wisata',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ConnectionStatusWidget(
        // Wrap aplikasi dengan ConnectionStatusWidget
        child: HomePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
