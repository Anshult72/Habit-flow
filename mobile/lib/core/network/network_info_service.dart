import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a stream and current state of network connectivity.
class NetworkInfoService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;

  NetworkInfoService() {
    _init();
  }

  bool get isOnline => _isOnline;
  Stream<bool> get onNetworkChange => _controller.stream;

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // If the list is empty or only contains 'none', we are offline.
    bool online = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(_isOnline);
    }
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    return _isOnline;
  }
}

final networkInfoProvider = Provider<NetworkInfoService>((ref) {
  return NetworkInfoService();
});
