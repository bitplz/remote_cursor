import 'dart:math' as math;
import 'dart:ui';
import 'package:vector_math/vector_math.dart' as vectors;
import 'package:remote_cursor/src/core/constants.dart';

class GyroToCoordinates {
  // Previous values for better filtering
  static DateTime? _lastTimestamp;
  static double _lastX = 0;
  static double _lastY = 0;

  // Adaptive thresholds based on movement speed
  static double baseVibrateThreshold = .4;
  static double jumpThreshold = 75.0;
  static double baseSensitivity = 2.5;

  // Smoothing variables
  static final List<Offset> _offsetHistory = [];

  // Calibration variables
  static double _calibrationOffsetX = 0;
  static double _calibrationOffsetY = 0;
  static bool _isCalibrated = false;
  static int _calibrationSamples = 0;

  // Diagonal movements detection variables
  static final double _axisBalanceFactor =
      1.5; // Balance factor between dominant and non-dominant axis
  static double _lastDominantAxis =
      0; // 0 = no movement, 1 = X dominant, 2 = Y dominant
  static int _consistentAxisCount = 0; // Counter for consistent axis dominance

  /// Reset calibration and history
  static void reset() {
    _lastTimestamp = null;
    _lastX = 0;
    _lastY = 0;
    _offsetHistory.clear();
    _isCalibrated = false;
    _calibrationSamples = 0;
    _calibrationOffsetX = 0;
    _calibrationOffsetY = 0;
    _lastDominantAxis = 0;
    _consistentAxisCount = 0;
  }

  /// Calibrate the gyroscope to account for natural drift
  static void startCalibration() {
    reset();
    _isCalibrated = false;
    _calibrationSamples = 0;
  }

  /// Transform raw gyroscope readings into usable cursor movement coordinates
  static Offset transformGyroscopeCoordinates(
    double x,
    double y,
    DateTime time,
  ) {
    // Initialize timestamp if first call
    if (_lastTimestamp == null) {
      _lastTimestamp = time;
      return Offset.zero;
    }

    // Calculate time delta in seconds for proper integration
    final diffMS = time.difference(_lastTimestamp!).inMicroseconds;
    final seconds = diffMS / 1000000;
    _lastTimestamp = time;

    // Skip processing for extremely short time periods
    if (seconds < 0.001 || seconds > 0.1) {
      return Offset.zero; // Invalid time delta, skip this sample
    }

    // Perform calibration if needed
    if (!_isCalibrated) {
      if (_calibrationSamples < GyroscopeDefaults.calibrationSampleCount) {
        _calibrationOffsetX += x;
        _calibrationOffsetY += y;
        _calibrationSamples++;
        return Offset.zero;
      } else {
        _calibrationOffsetX /= GyroscopeDefaults.calibrationSampleCount;
        _calibrationOffsetY /= GyroscopeDefaults.calibrationSampleCount;
        _isCalibrated = true;
      }
    }

    // Apply calibration correction
    x -= _calibrationOffsetX;
    y -= _calibrationOffsetY;

    // Adapt vibration threshold based on movement speed
    double adaptiveVibrateThreshold = baseVibrateThreshold;
    if (_lastX.abs() > 20 || _lastY.abs() > 20) {
      adaptiveVibrateThreshold =
          baseVibrateThreshold *
          1.2; // *** CHANGED: Reduced multiplier from 1.5 to 1.2 ***
    }

    // *** NEW: Improved diagonal detection ***
    // Determine the ratio between X and Y to detect diagonal intent
    double xAbs = x.abs();
    double yAbs = y.abs();
    double xyRatio = 0;

    if (xAbs > 0 && yAbs > 0) {
      xyRatio = xAbs / (xAbs + yAbs); // Normalized ratio between 0-1
    }

    // Detect diagonal intent (values near 0.5 indicate diagonal)
    bool isDiagonal =
        xAbs > baseVibrateThreshold &&
        yAbs > baseVibrateThreshold &&
        xyRatio > 0.3 &&
        xyRatio < 0.7;

    // *** CHANGED: Special threshold handling for diagonal movements ***
    if (isDiagonal) {
      // Use a lower threshold for both axes when diagonal motion is detected
      adaptiveVibrateThreshold *=
          0.7; // 30% lower threshold for diagonal motion
    }

    // Apply adaptive vibration threshold filter with special handling for diagonal motion
    bool xFiltered = false;
    bool yFiltered = false;

    if (x.abs() <= adaptiveVibrateThreshold) {
      x = 0;
      xFiltered = true;
    }

    if (y.abs() <= adaptiveVibrateThreshold) {
      y = 0;
      yFiltered = true;
    }

    // *** NEW: Balance axes to prevent dominant axis takeover ***
    // If one axis is much stronger, it tends to dominate and create horizontal/vertical-only movements
    if (!xFiltered && !yFiltered) {
      double dominantAxis = xAbs > yAbs ? 1 : 2;

      // Check for consistent axis dominance
      if (dominantAxis == _lastDominantAxis) {
        _consistentAxisCount++;
      } else {
        _consistentAxisCount = 0;
        _lastDominantAxis = dominantAxis;
      }

      // If same axis has been dominant for several samples, apply balancing
      if (_consistentAxisCount > GyroscopeDefaults.axisMemory) {
        if (dominantAxis == 1) {
          // X dominant
          // Boost Y axis to encourage diagonal movement
          y *=
              (1 +
                  (1 - _axisBalanceFactor) *
                      (_consistentAxisCount - GyroscopeDefaults.axisMemory) *
                      0.1);
        } else {
          // Y dominant
          // Boost X axis to encourage diagonal movement
          x *=
              (1 +
                  (1 - _axisBalanceFactor) *
                      (_consistentAxisCount - GyroscopeDefaults.axisMemory) *
                      0.1);
        }
      }
    }

    // Prevent massive jumps due to sudden gyro spikes
    if (y.abs() > jumpThreshold || x.abs() > jumpThreshold) {
      return Offset.zero;
    }

    // Store the raw values for next time's threshold adaptation
    _lastX = x;
    _lastY = y;

    // Convert angular velocity to degrees and apply sensitivity
    double adaptiveSensitivity = baseSensitivity;

    // Apply sensitivity boost for intentional fast movements
    final magnitude = sqrt(x * x + y * y);
    if (magnitude > 30) {
      adaptiveSensitivity *= 1 + ((magnitude - 30) / 30) * 0.3;
    }

    // *** NEW: Apply diagonal boost for balanced movement ***
    if (isDiagonal) {
      adaptiveSensitivity *=
          1.15; // 15% sensitivity boost for diagonal movements
    }

    // Convert to degrees and apply sensitivity
    double dx = vectors.degrees(x * seconds) * adaptiveSensitivity;
    double dy = vectors.degrees(y * seconds) * adaptiveSensitivity;

    // Create current offset
    Offset currentOffset = Offset(dx, dy);

    // Apply temporal smoothing using historical values
    if (_offsetHistory.isNotEmpty) {
      Offset avgHistoricalOffset = _offsetHistory.reduce(
        (value, element) =>
            Offset(value.dx + element.dx, value.dy + element.dy),
      );
      avgHistoricalOffset = Offset(
        avgHistoricalOffset.dx / _offsetHistory.length,
        avgHistoricalOffset.dy / _offsetHistory.length,
      );

      // Blend current with historical
      currentOffset = Offset(
        currentOffset.dx * (1 - GyroscopeDefaults.smoothingFactor) +
            avgHistoricalOffset.dx * GyroscopeDefaults.smoothingFactor,
        currentOffset.dy * (1 - GyroscopeDefaults.smoothingFactor) +
            avgHistoricalOffset.dy * GyroscopeDefaults.smoothingFactor,
      );
    }

    // Update history
    _offsetHistory.add(currentOffset);
    if (_offsetHistory.length > GyroscopeDefaults.historySize) {
      _offsetHistory.removeAt(0);
    }

    return currentOffset;
  }

  static double sqrt(double value) {
    return math.sqrt(value);
  }
}
