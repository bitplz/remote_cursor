import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:remote_cursor/src/core/models/mouse_action.dart';

/// A service for handling WebSocket connections for both gyroscope and trackpad data
class RemoteCursorConnection {
  /// WebSocket connection channel
  WebSocketChannel? _channel;

  /// Connection status
  bool _isConnected = false;

  /// Last error message
  String _lastError = "";

  /// Stream controller for broadcasting messages to subscribers
  final _connectionStatus =
      StreamController<bool>.broadcast();

  /// Stream of received WebSocket messages
  Stream<bool> get connectionStatusStream =>
      _connectionStatus.stream;

  /// Connection URL
  String? _url;

  /// Get the current connection URL
  String? get currentUrl => _url;
  
  String? get lastError => _lastError;
  bool get isConnected => _isConnected;


  /// Connect to a WebSocket server
  ///
  /// [url] The WebSocket server URL
  Future<void> connect(String url) async {
    if (_channel != null) {
      await disconnect();
    }

    try {
      _url = url;
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Listen for incoming messages
      _channel!.stream.listen((message) {},
        onError: (error) {
          _isConnected = false;
          _connectionStatus.add(_isConnected);
          _lastError = 'WebSocket error: $error';
          throw Exception('WebSocket error: $error');
        },
        onDone: () {
          _isConnected = false;
          _connectionStatus.add(_isConnected);
        },
      );

      _isConnected = true;
    } catch (e) {
      _lastError = 'Connection error: $e';
      _isConnected = false;
      _connectionStatus.add(_isConnected);
      throw Exception('Connection error: $e');
    }
  }

  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
      _isConnected = false;
      _connectionStatus.add(_isConnected);
      _url = null;
    }
  }

  /// Send a message to the WebSocket server
  void sendMessage(MouseActionConfig mouseActionConfig) {
    if (_channel == null || !_isConnected) {
      throw Exception('WebSocket channel must be connected before sending data.');
    }

    try {
      _channel!.sink.add(jsonEncode(mouseActionConfig.toJson));
    } catch (e) {
      _lastError = 'Send error: $e';
      throw Exception('Error sending data through websocket: $e');
    }
  }

  /// Send a custom message to the WebSocket server
  void sendCustomMessage(Map<String, dynamic> message) {
    if (_channel == null || !_isConnected) {
      throw Exception('WebSocket channel must be connected before sending data.');
    }

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      _lastError = 'Send error: $e';
      throw Exception('Error sending data through websocket: $e');
    }
  }

  /// Properly dispose of resources
  void dispose() {
    disconnect();
    _connectionStatus.close();
  }
}
