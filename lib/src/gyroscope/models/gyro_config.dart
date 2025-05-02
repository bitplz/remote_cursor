import 'dart:convert';
import '../../core/constants.dart';

/// Configuration options for the gyroscope controller
class GyroConfig {
  /// deadZone for ignoring tiny movements (0.0 to 1.0)
  final double deadZone;

  /// Smoothing factor for reducing jitter (0.0 to 1.0)
  final double smoothingFactor;

  /// Window size for moving average filter
  final int filterWindowSize;

  /// X-axis multiplier
  final int xMultiplier;

  /// Y-axis multiplier
  final int yMultiplier;

  /// Maximum number of events to batch before sending
  final int maxBatchSize;

  /// Minimum interval between updates in milliseconds
  final int minUpdateIntervalInMilliSec;

  /// Acceleration factor applied to motion
  final double accelerationFactor;

  /// Vertical sensitivity scaling
  final double verticalSensitivity;

  /// Horizontal sensitivity scaling
  final double horizontalSensitivity;

  /// Create a gyroscope configuration with custom or default values
  const GyroConfig({
    this.deadZone = GyroscopeDefaults.deadZone,
    this.smoothingFactor = GyroscopeDefaults.smoothingFactor,
    this.filterWindowSize = GyroscopeDefaults.filterWindowSize,
    this.xMultiplier = GyroscopeDefaults.xMultiplier,
    this.yMultiplier = GyroscopeDefaults.yMultiplier,
    this.maxBatchSize = GyroscopeDefaults.maxBatchSize,
    this.minUpdateIntervalInMilliSec = GyroscopeDefaults.minUpdateIntervalInMilliSec,
    this.accelerationFactor = GyroscopeDefaults.accelerationFactor,
    this.verticalSensitivity = GyroscopeDefaults.verticalSensitivity,
    this.horizontalSensitivity = GyroscopeDefaults.horizontalSensitivity,
  });

  /// Create a copy of this configuration with some values replaced
  GyroConfig copyWith({
    double? deadZone,
    double? smoothingFactor,
    int? filterWindowSize,
    int? xMultiplier,
    int? yMultiplier,
    int? maxBatchSize,
    int? minUpdateIntervalInMilliSec,
    double? accelerationFactor,
    double? verticalSensitivity,
    double? horizontalSensitivity,
  }) {
    return GyroConfig(
      deadZone: deadZone ?? this.deadZone,
      smoothingFactor: smoothingFactor ?? this.smoothingFactor,
      filterWindowSize: filterWindowSize ?? this.filterWindowSize,
      xMultiplier: xMultiplier ?? this.xMultiplier,
      yMultiplier: yMultiplier ?? this.yMultiplier,
      maxBatchSize: maxBatchSize ?? this.maxBatchSize,
      minUpdateIntervalInMilliSec: minUpdateIntervalInMilliSec ?? this.minUpdateIntervalInMilliSec,
      accelerationFactor: accelerationFactor ?? this.accelerationFactor,
      verticalSensitivity: verticalSensitivity ?? this.verticalSensitivity,
      horizontalSensitivity: horizontalSensitivity ?? this.horizontalSensitivity,
    );
  }

  /// Create a configuration from a JSON map
  factory GyroConfig.fromJson(Map<String, dynamic> json) {
    return GyroConfig(
      deadZone: json['deadZone'] ?? GyroscopeDefaults.deadZone,
      smoothingFactor: json['smoothingFactor'] ?? GyroscopeDefaults.smoothingFactor,
      filterWindowSize: json['filterWindowSize'] ?? GyroscopeDefaults.filterWindowSize,
      xMultiplier: json['xMultiplier'] ?? GyroscopeDefaults.xMultiplier,
      yMultiplier: json['yMultiplier'] ?? GyroscopeDefaults.yMultiplier,
      maxBatchSize: json['maxBatchSize'] ?? GyroscopeDefaults.maxBatchSize,
      minUpdateIntervalInMilliSec: json['minUpdateIntervalInMilliSec'] ?? GyroscopeDefaults.minUpdateIntervalInMilliSec,
      accelerationFactor: (json['accelerationFactor'] ?? GyroscopeDefaults.accelerationFactor).toDouble(),
      verticalSensitivity: (json['verticalSensitivity'] ?? GyroscopeDefaults.verticalSensitivity).toDouble(),
      horizontalSensitivity: (json['horizontalSensitivity'] ?? GyroscopeDefaults.horizontalSensitivity).toDouble(),
    );
  }

  /// Convert this configuration to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'deadZone': deadZone,
      'smoothingFactor': smoothingFactor,
      'filterWindowSize': filterWindowSize,
      'xMultiplier': xMultiplier,
      'yMultiplier': yMultiplier,
      'maxBatchSize': maxBatchSize,
      'minUpdateIntervalInMilliSec': minUpdateIntervalInMilliSec,
      'accelerationFactor': accelerationFactor,
      'verticalSensitivity': verticalSensitivity,
      'horizontalSensitivity': horizontalSensitivity,
    };
  }

  /// Create a configuration from a JSON string
  factory GyroConfig.fromJsonString(String jsonString) {
    return GyroConfig.fromJson(json.decode(jsonString));
  }

  /// Convert this configuration to a JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  /// Default configuration
  static const GyroConfig defaultConfig = GyroConfig();

  @override
  String toString() {
    return 'GyroConfig{deadZone: $deadZone, smoothingFactor: $smoothingFactor, '
        'filterWindowSize: $filterWindowSize, xMultiplier: $xMultiplier, yMultiplier: $yMultiplier, '
        'maxBatchSize: $maxBatchSize, minUpdateIntervalInMilliSec: $minUpdateIntervalInMilliSec, '
        'accelerationFactor: $accelerationFactor, verticalSensitivity: $verticalSensitivity, '
        'horizontalSensitivity: $horizontalSensitivity}';
  }
}
