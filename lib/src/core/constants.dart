/// Message types for WebSocket communication
class MessageTypes {
  static const String trackpad = 'trackpad';
  static const String gyroscope = 'gyroscope';
}

/// Default values for trackpad configuration
class TrackpadDefaults {
  static const double sensitivity = 1.0;
  static const double maxSpeed = 20.0;
  static const int sampleRate = 60; // Hz
  static const double deadZone = 0.05;
  static const double minMovementThreshold = 0.2;
  static const double velocitySmoothing = 0.8;
  static const int maxBatchSize = 3;
  static const double baseSendMultiplier = 5.0;
  static const double deltaMultiplier = 4.2;
  static const double predictiveFactor = 0.3;
  static const double speedDivisor = 10.0;
  static const double maxTouchpadWidth = 400.0;
  static const double maxTouchpadHeight = 400.0;
  static const int minUpdateIntervalMs = 5;
  static const double horizontalSensitivity = 1.6;
  static const double verticalSensitivity = 1.0;
  static const double accelerationCurve = 1.0;
}

/// Default values for gyroscope configuration
class GyroscopeDefaults {
  static const double sensitivity = 1.0;
  static const double verticalSensitivity = 2.0;
  static const double horizontalSensitivity = 2.0;
  static const double maxRotationRate = 5.0; // rad/s
  static const int sampleRate = 60; // Hz
  static const double smoothingFactor = 0.85;
  static const double deadZone = 0.05;
  static const int calibrationSampleCount = 10;
  static const int axisMemory = 2;
  static const int historySize = 3;
  static const int filterWindowSize = 3;
  static const int xMultiplier = 3;
  static const int yMultiplier = 3;
  static const int maxBatchSize = 4;
  static const int minUpdateIntervalInMilliSec = 6;
  static const double accelerationFactor = 2.3;
}

/// Keys for persistent storage
class StorageKeys {
  static const String trackpadConfig = 'trackpad_config';
  static const String gyroConfig = 'gyro_config';
  static const String lastWebSocketUrl = 'last_websocket_url';
}
