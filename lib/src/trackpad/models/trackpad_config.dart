import 'dart:convert';
import '../../core/constants.dart';

/// Configuration options for the trackpad controller
class TrackpadConfig {
  /// Horizontal movement sensitivity
  final double horizontalSensitivity;

  /// Vertical movement sensitivity
  final double verticalSensitivity;

  /// Predictive factor used in estimating future movement
  final double predictiveFactor;

  /// Multiplier for delta values applied to movement
  final double deltaMultiplier;

  /// Base multiplier for sending data values to server
  final double baseSendMultiplier;

  /// Curve factor for acceleration behavior
  final double accelerationCurve;

  /// Divisor used to scale final movement speed
  final double speedDivisor;

  /// Maximum number of events to batch before sending
  final int maxBatchSize;

  /// Minimum interval between update sends in milliseconds
  final int minUpdateIntervalMs;

  /// Smoothing factor applied to velocity calculations
  final double velocitySmoothing;

  /// Movement threshold below which motion is ignored
  final double minMovementThreshold;

  /// Maximum height of the virtual touchpad in logical pixels
  final double maxTouchpadHeight;

  /// Maximum width of the virtual touchpad in logical pixels
  final double maxTouchpadWidth;

  /// Create a trackpad configuration with custom or default values
  const TrackpadConfig({
    this.horizontalSensitivity = TrackpadDefaults.horizontalSensitivity,
    this.verticalSensitivity = TrackpadDefaults.verticalSensitivity,
    this.predictiveFactor = TrackpadDefaults.predictiveFactor,
    this.deltaMultiplier = TrackpadDefaults.deltaMultiplier,
    this.baseSendMultiplier = TrackpadDefaults.baseSendMultiplier,
    this.accelerationCurve = TrackpadDefaults.accelerationCurve,
    this.speedDivisor = TrackpadDefaults.speedDivisor,
    this.maxBatchSize = TrackpadDefaults.maxBatchSize,
    this.minUpdateIntervalMs = TrackpadDefaults.minUpdateIntervalMs,
    this.velocitySmoothing = TrackpadDefaults.velocitySmoothing,
    this.minMovementThreshold = TrackpadDefaults.minMovementThreshold,
    this.maxTouchpadHeight = TrackpadDefaults.maxTouchpadHeight,
    this.maxTouchpadWidth = TrackpadDefaults.maxTouchpadWidth,
  });

  /// Create a copy of this configuration with some values replaced
  TrackpadConfig copyWith({
    double? horizontalSensitivity,
    double? verticalSensitivity,
    double? predictiveFactor,
    double? deltaMultiplier,
    double? baseSendMultiplier,
    double? accelerationCurve,
    double? speedDivisor,
    int? maxBatchSize,
    int? minUpdateIntervalMs,
    double? velocitySmoothing,
    double? minMovementThreshold,
    double? maxTouchpadHeight,
    double? maxTouchpadWidth,
  }) {
    return TrackpadConfig(
      horizontalSensitivity: horizontalSensitivity ?? this.horizontalSensitivity,
      verticalSensitivity: verticalSensitivity ?? this.verticalSensitivity,
      predictiveFactor: predictiveFactor ?? this.predictiveFactor,
      deltaMultiplier: deltaMultiplier ?? this.deltaMultiplier,
      baseSendMultiplier: baseSendMultiplier ?? this.baseSendMultiplier,
      accelerationCurve: accelerationCurve ?? this.accelerationCurve,
      speedDivisor: speedDivisor ?? this.speedDivisor,
      maxBatchSize: maxBatchSize ?? this.maxBatchSize,
      minUpdateIntervalMs: minUpdateIntervalMs ?? this.minUpdateIntervalMs,
      velocitySmoothing: velocitySmoothing ?? this.velocitySmoothing,
      minMovementThreshold: minMovementThreshold ?? this.minMovementThreshold,
      maxTouchpadHeight: maxTouchpadHeight ?? this.maxTouchpadHeight,
      maxTouchpadWidth: maxTouchpadWidth ?? this.maxTouchpadWidth,
    );
  }

  /// Create a configuration from a JSON map
  factory TrackpadConfig.fromJson(Map<String, dynamic> json) {
    return TrackpadConfig(
      horizontalSensitivity: json['horizontalSensitivity'] ?? TrackpadDefaults.horizontalSensitivity,
      verticalSensitivity: json['verticalSensitivity'] ?? TrackpadDefaults.verticalSensitivity,
      predictiveFactor: json['predictiveFactor'] ?? TrackpadDefaults.predictiveFactor,
      deltaMultiplier: json['deltaMultiplier'] ?? TrackpadDefaults.deltaMultiplier,
      baseSendMultiplier: json['baseSendMultiplier'] ?? TrackpadDefaults.baseSendMultiplier,
      accelerationCurve: json['accelerationCurve'] ?? TrackpadDefaults.accelerationCurve,
      speedDivisor: json['speedDivisor'] ?? TrackpadDefaults.speedDivisor,
      maxBatchSize: json['maxBatchSize'] ?? TrackpadDefaults.maxBatchSize,
      minUpdateIntervalMs: json['minUpdateIntervalMs'] ?? TrackpadDefaults.minUpdateIntervalMs,
      velocitySmoothing: json['velocitySmoothing'] ?? TrackpadDefaults.velocitySmoothing,
      minMovementThreshold: json['minMovementThreshold'] ?? TrackpadDefaults.minMovementThreshold,
      maxTouchpadHeight: json['maxTouchpadHeight'] ?? TrackpadDefaults.maxTouchpadHeight,
      maxTouchpadWidth: json['maxTouchpadWidth'] ?? TrackpadDefaults.maxTouchpadWidth,
    );
  }

  /// Convert this configuration to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'horizontalSensitivity': horizontalSensitivity,
      'verticalSensitivity': verticalSensitivity,
      'predictiveFactor': predictiveFactor,
      'deltaMultiplier': deltaMultiplier,
      'baseSendMultiplier': baseSendMultiplier,
      'accelerationCurve': accelerationCurve,
      'speedDivisor': speedDivisor,
      'maxBatchSize': maxBatchSize,
      'minUpdateIntervalMs': minUpdateIntervalMs,
      'velocitySmoothing': velocitySmoothing,
      'minMovementThreshold': minMovementThreshold,
      'maxTouchpadHeight': maxTouchpadHeight,
      'maxTouchpadWidth': maxTouchpadWidth,
    };
  }

  /// Create a configuration from a JSON string
  factory TrackpadConfig.fromJsonString(String jsonString) {
    return TrackpadConfig.fromJson(json.decode(jsonString));
  }

  /// Convert this configuration to a JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  /// Default configuration
  static const TrackpadConfig defaultConfig = TrackpadConfig();

  @override
  String toString() {
    return 'TrackpadConfig{horizontalSensitivity: $horizontalSensitivity, '
        'verticalSensitivity: $verticalSensitivity, predictiveFactor: $predictiveFactor, '
        'deltaMultiplier: $deltaMultiplier, baseSendMultiplier: $baseSendMultiplier, '
        'accelerationCurve: $accelerationCurve, speedDivisor: $speedDivisor, '
        'maxBatchSize: $maxBatchSize, minUpdateIntervalMs: $minUpdateIntervalMs, '
        'velocitySmoothing: $velocitySmoothing, minMovementThreshold: $minMovementThreshold, '
        'maxTouchpadHeight: $maxTouchpadHeight, maxTouchpadWidth: $maxTouchpadWidth}';
  }
}
