class WebSocketConfig {
  final String ip;
  final int port;

  WebSocketConfig({required this.ip, required this.port}) {
    if (ip.isEmpty) {
      throw ArgumentError('IP address cannot be empty');
    }

    if (port < 1 || port > 65535) {
      throw ArgumentError('Port must be between 1 and 65535');
    }
  }

  String get url => 'ws://$ip:$port';
}
