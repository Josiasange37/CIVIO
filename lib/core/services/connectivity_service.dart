import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  
  final _controller = StreamController<bool>.broadcast();
  bool _isConnected = true;
  
  /// Stream of connectivity status changes
  Stream<bool> get onConnectivityChanged => _controller.stream;
  
  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Initialize and start listening to connectivity changes
  Future<void> initialize() async {
    // Check initial status
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    
    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    if (wasConnected != _isConnected) {
      _controller.add(_isConnected);
    }
  }

  /// Check if currently connected to internet
  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    return _isConnected;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
