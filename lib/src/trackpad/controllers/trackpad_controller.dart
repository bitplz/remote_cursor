import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:remote_cursor/src/core/models/mouse_action.dart';
import 'package:remote_cursor/src/trackpad/models/trackpad_config.dart';
import '../../core/di/service_locator.dart';
import '../../core/state/remote_cursor_connection_service.dart';
import '../../utils/vector_2d.dart';

/// Controller that handles trackpad interactions and WebSocket communication
class TrackpadController {
  // Singleton instance

  final RemoteCursorConnection _webSocketService = RemoteCursor.get<RemoteCursorConnection>();

  static TrackpadController get instance =>
      RemoteCursor.get<TrackpadController>();

  // Gesture tracking variables
  double _dx = 100.0;
  double _dy = 100.0;
  double _previousDx = 100.0;
  double _previousDy = 100.0;
  double _sensitivity = 1.05;

  // Movement processing variables
  final Offset _pendingDelta = Offset.zero;
  DateTime _lastSent = DateTime.now();
  Vector2D _currentVelocity = Vector2D(0, 0);
  final List<Vector2D> _movementBatch = [];
  
  late TrackpadConfig _config = TrackpadConfig.defaultConfig;

  /// Sets the sensitivity of the trackpad
  void setSensitivity(double value) {
    _sensitivity = value;
  }

  /// Initialize WebSocket connection
  TrackpadController({TrackpadConfig? config}) {
    RemoteCursor.ensureInitialized();
    _initialize(config: config);
  }


  /// Initialize the controller with custom configuration.
  ///
  /// This method should be called before using the controller.
  /// If not called explicitly, default configuration will be used.
  void _initialize({TrackpadConfig? config}) {
    initConfig();
    // Setup connection to WebSocket if URL is provided
    if (!_webSocketService.isConnected) {
      throw UnimplementedError('Websocket Not Initialized!');
    }
  }

  initConfig({TrackpadConfig? config}) {
    _config = TrackpadConfig.defaultConfig.copyWith(
      horizontalSensitivity: config?.horizontalSensitivity,
      verticalSensitivity: config?.verticalSensitivity,
      predictiveFactor: config?.predictiveFactor,
      deltaMultiplier: config?.deltaMultiplier,
      baseSendMultiplier: config?.baseSendMultiplier,
      accelerationCurve: config?.accelerationCurve,
      speedDivisor: config?.speedDivisor,
      maxBatchSize: config?.maxBatchSize,
      minUpdateIntervalMs: config?.minUpdateIntervalMs,
      velocitySmoothing: config?.velocitySmoothing,
      minMovementThreshold: config?.minMovementThreshold,
      maxTouchpadHeight: config?.maxTouchpadHeight,
      maxTouchpadWidth: config?.maxTouchpadWidth,
    );
  }

  /// Sends movement or action command to the server
  void _sendMovement(MouseActionConfig mouseActionConfig) {
    _webSocketService.sendMessage(mouseActionConfig);
  }

  /// Sends custom data or action command to the server
  void sendCustomData(Map<String, dynamic> data) {
    _webSocketService.sendCustomMessage(data);
  }

  /// Handles pan update event and processes movement
  void onDrag(Offset delta) {
    final newDelta = delta * _config.deltaMultiplier;
    _handleDragUpdate(newDelta);
  }

  /// Processes drag updates with acceleration and smoothing
  void _handleDragUpdate(Offset delta) {
    // Clamp position within touchpad bounds
    _dx = (_previousDx + delta.dx).clamp(
      0.0,
      _config.maxTouchpadWidth,
    );
    _dy = (_previousDy + delta.dy).clamp(
      0.0,
      _config.maxTouchpadHeight,
    );

    _previousDx = _dx;
    _previousDy = _dy;

    // Create movement vector from touch delta
    final vector = Vector2D(delta.dx, delta.dy);

    // Skip processing if movement is too small
    if (vector.length < _config.minMovementThreshold) return;

    // Update velocity with exponential smoothing
    _currentVelocity = Vector2D(
      _currentVelocity.x * _config.velocitySmoothing +
          vector.x * (1 - _config.velocitySmoothing),
      _currentVelocity.y * _config.velocitySmoothing +
          vector.y * (1 - _config.velocitySmoothing),
    );

    // Add to batch for processing
    _movementBatch.add(vector);

    // Process the batch if we've reached max size or enough time has passed
    final now = DateTime.now();
    final timeDelta = now.difference(_lastSent).inMilliseconds;

    if (_movementBatch.length >= _config.maxBatchSize ||
        timeDelta >= _config.minUpdateIntervalMs) {
      _processBatch(now);
    }
  }

  /// Processes a batch of movement vectors
  void _processBatch(DateTime now) {
    if (_movementBatch.isEmpty) return;

    // Calculate average movement from batch
    Vector2D avgMovement = _movementBatch.fold(
      Vector2D(0, 0),
      (Vector2D sum, Vector2D v) => Vector2D(sum.x + v.x, sum.y + v.y),
    );

    avgMovement = Vector2D(
      avgMovement.x / _movementBatch.length,
      avgMovement.y / _movementBatch.length,
    );

    // Clear the batch
    _movementBatch.clear();
    _lastSent = now;

    // Skip if movement is too small after averaging
    if (!avgMovement.canNormalize) return;

    // Calculate speed factor with non-linear acceleration for larger movements
    final normalized = avgMovement.normalized;
    final speedBase = avgMovement.length / _config.speedDivisor;
    final speedFactor =
        math.pow(speedBase, _config.accelerationCurve).toDouble();

    // Apply sensitivity and prepare movement values
    final dxSend =
        normalized.x * speedFactor * _config.horizontalSensitivity;
    final dySend =
        normalized.y * speedFactor * _config.verticalSensitivity;

    // Add predictive movement based on velocity for smoother cursor motion
    final dxPredictive =
        (dxSend + (_currentVelocity.x * _config.predictiveFactor)) *
        _sensitivity *
        _config.baseSendMultiplier;
    final dyPredictive =
        (dySend + (_currentVelocity.y * _config.predictiveFactor)) *
        _sensitivity *
        _config.baseSendMultiplier;

    _sendMovement(
      MouseActionConfig(
        dx: dxPredictive,
        dy: dyPredictive,
        mouseAction: MouseAction.move,
      ),
    );
  }

  /// Sends a click action
  void sendClick() {
    _sendMovement(
      MouseActionConfig(
        dx: _pendingDelta.dx,
        dy: _pendingDelta.dy,
        mouseAction: MouseAction.click,
      ),
    );
  }

  /// Sends a double click action
  void sendDoubleClick() {
    _sendMovement(
      MouseActionConfig(
        dx: _pendingDelta.dx,
        dy: _pendingDelta.dy,
        mouseAction: MouseAction.doubleClick,
      ),
    );
  }

  /// Sends a right click action
  void sendRightClick() {
    _sendMovement(
      MouseActionConfig(
        dx: _pendingDelta.dx,
        dy: _pendingDelta.dy,
        mouseAction: MouseAction.rightClick,
      ),
    );
  }
}
