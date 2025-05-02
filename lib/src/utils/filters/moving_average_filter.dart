import 'dart:collection';

import '../vector_2d.dart';

/// A filter that computes a moving average over a window of samples.
///
/// This is useful for smoothing noisy sensor data like gyroscope readings.
class MovingAverageFilter {
  /// The maximum number of samples to keep in the window.
  final int windowSize;

  /// The samples currently in the window.
  final Queue<double> _samples = Queue<double>();

  /// The current sum of all samples in the window.
  double _sum = 0.0;

  /// Creates a moving average filter with the specified window size.
  ///
  /// The [windowSize] must be greater than 0.
  MovingAverageFilter({this.windowSize = 3})
    : assert(windowSize > 0, 'Window size must be greater than 0');

  /// Adds a new sample to the filter and returns the current average.
  ///
  /// This method adds the sample to the window, removes the oldest sample
  /// if the window is full, and returns the average of all samples in the window.
  double addSample(double value) {
    // Add the new sample
    _samples.add(value);
    _sum += value;

    // Remove the oldest sample if the window is full
    if (_samples.length > windowSize) {
      _sum -= _samples.removeFirst();
    }

    // Return the current average
    return _sum / _samples.length;
  }

  /// Returns the current average of all samples in the window.
  double get average => _samples.isEmpty ? 0.0 : _sum / _samples.length;

  /// Returns the number of samples currently in the window.
  int get sampleCount => _samples.length;

  /// Clears all samples from the window.
  void reset() {
    _samples.clear();
    _sum = 0.0;
  }
}

/// A filter that computes a moving average for 2D vectors.
///
/// This is useful for smoothing 2D motion data like touch or gyroscope input.
class Vector2DMovingAverageFilter {
  /// The x-component filter.
  final MovingAverageFilter _xFilter;

  /// The y-component filter.
  final MovingAverageFilter _yFilter;

  /// Creates a vector moving average filter with the specified window size.
  ///
  /// The [windowSize] must be greater than 0.
  Vector2DMovingAverageFilter({required int windowSize})
    : _xFilter = MovingAverageFilter(windowSize: windowSize),
      _yFilter = MovingAverageFilter(windowSize: windowSize);

  /// Adds a new vector sample to the filter and returns the current average.
  Vector2D addSample(Vector2D value) {
    final x = _xFilter.addSample(value.x);
    final y = _yFilter.addSample(value.y);
    return Vector2D(x, y);
  }

  /// Returns the current average vector.
  Vector2D get average => Vector2D(_xFilter.average, _yFilter.average);

  /// Clears all samples from the window.
  void reset() {
    _xFilter.reset();
    _yFilter.reset();
  }
}
