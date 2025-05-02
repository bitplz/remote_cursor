/// Configuration model for WebSocket connections.
class ConnectionConfig {
  /// The server IP address
  final String serverIp;

  /// The server port
  final int port;

  /// Connection timeout in milliseconds
  final int timeoutMs;

  /// Creates a new connection configuration
  ///
  /// Defaults to local IP and port 44213 if not specified
  ConnectionConfig({
    this.serverIp = '192.168.1.109',
    this.port = 44213,
    this.timeoutMs = 5000,
  });

  /// Creates a copy of this config with modified fields
  ConnectionConfig copyWith({String? serverIp, int? port, int? timeoutMs}) {
    return ConnectionConfig(
      serverIp: serverIp ?? this.serverIp,
      port: port ?? this.port,
      timeoutMs: timeoutMs ?? this.timeoutMs,
    );
  }
}

/// Connection status constants
class ConnectionStatus {
  static const String connecting = 'Connecting';
  static const String connected = 'Connected';
  static const String disconnected = 'Disconnected';
  static const String failed = 'Connection failed';
}
