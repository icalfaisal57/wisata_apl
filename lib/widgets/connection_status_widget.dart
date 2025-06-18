import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionStatusWidget extends StatefulWidget {
  final Widget child;
  const ConnectionStatusWidget({Key? key, required this.child})
    : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
      _showConnectivitySnackBar(result);
    });
  }

  Future<void> _initConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = result;
    });
  }

  void _showConnectivitySnackBar(ConnectivityResult result) {
    String message;
    Color color;
    if (result == ConnectivityResult.none) {
      message = 'Anda sedang offline. Beberapa fitur mungkin tidak berfungsi.';
      color = Colors.red;
    } else {
      message = 'Anda kembali online.';
      color = Colors.green;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_connectivityResult == ConnectivityResult.none)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.red.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: const Center(
                child: Text(
                  'Anda sedang offline. Data mungkin tidak terbaru.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
