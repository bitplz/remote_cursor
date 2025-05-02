import 'package:get_it/get_it.dart';
import '../../gyroscope/controllers/gyro_controller.dart';
import '../../trackpad/controllers/trackpad_controller.dart';
import '../models/websocket_config.dart';
import '../state/remote_cursor_connection_service.dart';

/// Service locator for dependency injection using GetIt.
///
/// This class provides a centralized way to register and access
/// singleton instances of services and controllers throughout the package.
class RemoteCursor {
  // Private constructor
  RemoteCursor._();

  // Singleton GetIt instance
  static final GetIt instance = GetIt.instance;

  // Flag to track initialization state
  static bool _isInitialized = false;

  static TrackpadController get trackpadController => _getTrackPadController();
  static RemoteCursorConnection get remoteCursorConnection => _getRemoteCursorConnection();
  static GyroController get gyroController => _getGyroController();

  /// Initialize the service locator with required dependencies
  static Future<void> init({required WebSocketConfig webSocketConfig}) async {
    final String url = webSocketConfig.url;

    if (!instance.isRegistered<RemoteCursorConnection>()) {
      final webSocketService = RemoteCursorConnection();
      await webSocketService.connect(url);
      instance.registerSingleton<RemoteCursorConnection>(
        webSocketService,
        dispose: (s) => s.dispose(),
      );
    }

    if (!instance.isRegistered<GyroController>()) {
      instance.registerLazySingleton<GyroController>(
            () => GyroController(),
      );
    }

    if (!instance.isRegistered<TrackpadController>()) {
      instance.registerLazySingleton<TrackpadController>(
            () => TrackpadController(),
      );
    }

    _isInitialized = true;

  }

  static TrackpadController _getTrackPadController() {
    return get<TrackpadController>();
  }

  static RemoteCursorConnection _getRemoteCursorConnection() {
    return get<RemoteCursorConnection>();
  }

  static GyroController _getGyroController() {
    return get<GyroController>();
  }

  /// Check if the service is initialized
  static void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('WebsocketMouseService not initialized!. Make sure WebsocketMouseService.init() was called successfully.');
    }
  }

  /// Get a registered service with initialization check
  static T get<T extends Object>() {
    ensureInitialized();
    try {
      return instance.get<T>();
    } catch (e) {
      throw StateError('Service of type $T is not registered. Make sure WebsocketMouseService.init() was called successfully.');
    }
  }

  /// Checks if a specific service is registered
  static bool isRegistered<T extends Object>() {
    return instance.isRegistered<T>();
  }

  /// Dispose all registered services and their resources
  static Future<void> dispose() async {
    if (!_isInitialized) return; // Silently return if not initialized
    await instance.reset(dispose: true);
    _isInitialized = false;
  }
}
