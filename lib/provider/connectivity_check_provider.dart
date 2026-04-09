import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final Connectivity _connectivity = Connectivity();

  InternetProvider() {
    _init();
  }


  void _init() {
    _checkInitialConnection();
    _listenConnection();
  }
  
  // this method is used to check the internet connection
  Future<void> _checkInitialConnection() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    _updateConnection(result);
  }
  
  void _listenConnection() {
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnection(result);
    });
  }

  void _updateConnection(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      _isConnected = false;
    } else {
      _isConnected = true;
    }

    notifyListeners();
  }
}
