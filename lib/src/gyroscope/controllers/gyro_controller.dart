import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:remote_cursor/src/core/models/mouse_action.dart';
import '../../core/di/service_locator.dart';
import '../../core/state/remote_cursor_connection_service.dart';
import '../../utils/coordinate_transformer.dart';
import '../../utils/filters/moving_average_filter.dart';
import '../../utils/vector_2d.dart';
import '../models/gyro_config.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Controller for handling gyroscope data and operations.
///
/// This controller manages gyroscope sensor data, applies filters,
/// and provides processed data to widgets.
class GyroController {
  /// Singleton instance getter through GetIt
  final RemoteCursorConnection _webSocketService = RemoteCursor.get<RemoteCursorConnection>();

  static GyroController get instance =>
      RemoteCursor.get<GyroController>();

  // Observable state variables
  Vector2D _gyroData = Vector2D(0, 0);
  bool _isActive = false;
  late GyroConfig _config = GyroConfig();

  // Reference to the WebSocket service

  // Filters for smoothing gyroscope data
  late MovingAverageFilter _xFilter;
  late MovingAverageFilter _yFilter;
  Vector2D _smoothedVector = Vector2D(0, 0);
  final List<Vector2D> _gyroBatch = [];
  late DateTime _lastSent = DateTime.now();

  // Stream subscription for gyroscope data
  StreamSubscription? _gyroSubscription;
  final StreamController<Vector2D> _gyroDataStreamController = StreamController<Vector2D>.broadcast();
  Stream<Vector2D> get gyroDataStream => _gyroDataStreamController.stream;

  // Getters for reactive state
  // Vector2D get gyroData => _gyroData;
  bool get isActive => _isActive;


  /// Creates a new instance of GyroController.
  ///
  /// Usually, you should access the controller through [GyroController.instance]
  /// instead of creating a new instance directly.
  GyroController({GyroConfig? config}) {
    RemoteCursor.ensureInitialized();
    _initialize(config: config);
  }

  /// Initialize the controller with custom configuration.
  ///
  /// This method should be called before using the controller.
  /// If not called explicitly, default configuration will be used.
  void _initialize({GyroConfig? config}) {
    initConfig(config: config);
    _initializeFilters();

    // Setup connection to WebSocket if URL is provided
    if (!_webSocketService.isConnected) {
      throw UnimplementedError('Websocket Not Initialized!');
    }
  }

  initConfig({GyroConfig? config}) {
    _config = GyroConfig.defaultConfig.copyWith(
      deadZone: config?.deadZone,
      smoothingFactor: config?.smoothingFactor,
      filterWindowSize: config?.filterWindowSize,
      xMultiplier: config?.xMultiplier,
      yMultiplier: config?.yMultiplier,
      maxBatchSize: config?.maxBatchSize,
      minUpdateIntervalInMilliSec: config?.minUpdateIntervalInMilliSec,
      accelerationFactor: config?.accelerationFactor,
      verticalSensitivity: config?.verticalSensitivity,
      horizontalSensitivity: config?.horizontalSensitivity,
    );
  }

  /// Initializes the data filters based on current configuration
  void _initializeFilters() {
    _xFilter = MovingAverageFilter(
      windowSize: _config.filterWindowSize,
    );
    _yFilter = MovingAverageFilter(
      windowSize: _config.filterWindowSize,
    );
  }

  activate() {
    _startGyroscope();
  }

  deactivate() {
    _stopGyroscope();
  }

  pause() {
    _gyroSubscription?.pause();
    _isActive = false;
  }

  /// Start listening to gyroscope data
  Future<void> _startGyroscope() async {
    if (_isActive) return;

    try {
      // Start listening to the message stream
      if (_gyroSubscription != null && _gyroSubscription!.isPaused){
        _gyroSubscription!.resume();
      } else {
        _subscribeToGyroscopeData();
      }
      _isActive = true;
    } catch (e) {
      // Handle connection errors
      throw UnimplementedError("Error starting gyroscope: $e");
    }
  }

  /// Stop listening to gyroscope data
  void _stopGyroscope() {
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _gyroDataStreamController.close();
    _isActive = false;
  }

  /// Subscribe to gyroscope data from the WebSocket service
  void _subscribeToGyroscopeData() {
    // _gyroSubscription?.cancel();

    _gyroSubscription = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 16),
    ).listen((event) {
      Offset coordinates = GyroToCoordinates.transformGyroscopeCoordinates(
        event.z * -1 * _config.yMultiplier,
        event.x * -1 * _config.xMultiplier,
        event.timestamp,
      );

      // Create movement vector from gyro data
      final vector = Vector2D(coordinates.dx, coordinates.dy);

      // Apply dead zone to ignore very small movements
      if (vector.length < _config.deadZone) return;

      // Apply moving average filter to smooth out jitter
      final filteredX = _xFilter.addSample(vector.x);
      final filteredY = _yFilter.addSample(vector.y);
      final filteredVector = Vector2D(filteredX, filteredY);

      // Apply exponential smoothing for more natural movement
      _smoothedVector = Vector2D(
        _smoothedVector.x * _config.smoothingFactor +
            filteredVector.x * (1 - _config.smoothingFactor),
        _smoothedVector.y * _config.smoothingFactor +
            filteredVector.y * (1 - _config.smoothingFactor),
      );

      // Skip if movement is too small after smoothing
      if (!_smoothedVector.canNormalize) return;

      // Add to batch for processing
      _gyroBatch.add(_smoothedVector);

      // Check if we should process the batch
      final now = DateTime.now();
      final timeDelta = now.difference(_lastSent).inMilliseconds;

      if (_gyroBatch.length >= _config.maxBatchSize ||
          timeDelta >= _config.minUpdateIntervalInMilliSec) {
        _processGyroBatch(now);
      }
    });
  }

  void _processGyroBatch(DateTime now) {
    try {
      if (_gyroBatch.isEmpty) return;

      // Calculate average movement from batch
      Vector2D avgMovement = _gyroBatch.fold(
        Vector2D(0, 0),
        (Vector2D sum, Vector2D v) => Vector2D(sum.x + v.x, sum.y + v.y),
      );

      avgMovement = Vector2D(
        avgMovement.x / _gyroBatch.length,
        avgMovement.y / _gyroBatch.length,
      );

      _gyroData = avgMovement;
      _gyroDataStreamController.add(_gyroData);


      // Clear the batch and update last sent time
      _gyroBatch.clear();
      _lastSent = now;

      // Skip if movement is too small after averaging
      if (!avgMovement.canNormalize) return;

      // Apply non-linear acceleration curve for better control
      final normalized = avgMovement.normalized;
      final magnitude = avgMovement.length;

      // Non-linear response curve - more precise for small movements, faster for large ones
      double speedFactor;
      if (magnitude < 0.3) {
        // Slow movement for precision
        speedFactor = _config.accelerationFactor * magnitude * 0.7;
      } else if (magnitude < 0.7) {
        // Medium speed for regular movement
        speedFactor = _config.accelerationFactor * magnitude;
      } else {
        // Faster movement with additional boost for larger movements
        speedFactor =
            _config.accelerationFactor *
            (magnitude + (magnitude - 0.7) * 0.8);
      }

      // Calculate final movement values
      final dxSend =
          normalized.x * speedFactor * _config.horizontalSensitivity;
      final dySend =
          normalized.y * speedFactor * _config.verticalSensitivity;



      // Send the movement over WebSocket
      _sendMovement(
        MouseActionConfig(
          dx: dxSend,
          dy: dySend,
          mouseAction: MouseAction.move,
        ),
      );
    } catch (e) {
      throw Exception('Error processing gyro data: $e');
    }
  }
  /// Send gyroscope data to server
  _sendMovement(MouseActionConfig mouseActionConfig) {
    _webSocketService.sendMessage(mouseActionConfig);
  }

  /// Sends custom data or action command to the server
  void sendCustomData(Map<String, dynamic> data) {
    _webSocketService.sendCustomMessage(data);
  }


  /// Calibrate the gyroscope to adjust for drift
  void calibrate() {
    // Reset filters and any calibration variables
    _xFilter.reset();
    _yFilter.reset();


    // Send calibration command to server
    // sendGyroData({'action': 'calibrate'});
  }

  /// Reset all gyroscope data and state
  void reset() {
    _gyroData = Vector2D(0, 0);
    _gyroDataStreamController.add(_gyroData);
    _xFilter.reset();
    _yFilter.reset();
  }

  void dispose() {
    _stopGyroscope();
  }


}
