import 'dart:math' as math;
import 'dart:ui';

/// A two-dimensional vector utility class for handling coordinate manipulations.
///
/// This class provides common vector operations like normalization, addition,
/// subtraction, and other mathematical operations useful for processing
/// motion data.
class Vector2D {
  /// The x component of the vector
  final double x;

  /// The y component of the vector
  final double y;

  /// Creates a 2D vector with the given x and y components.
  const Vector2D(this.x, this.y);

  /// Creates a Vector2D from an Offset.
  factory Vector2D.fromOffset(Offset offset) => Vector2D(offset.dx, offset.dy);

  /// Creates a zero vector (0,0).
  static const zero = Vector2D(0, 0);

  /// Returns the squared length of the vector.
  ///
  /// This is more efficient than [length] when only comparing distances,
  /// as it avoids the square root calculation.
  double get lengthSquared => x * x + y * y;

  /// Returns the length (magnitude) of the vector.
  double get length => math.sqrt(lengthSquared);

  /// Returns whether this vector can be normalized.
  ///
  /// A vector can be normalized if its length is not zero.
  bool get canNormalize => length > 0;

  /// Returns a new vector with the same direction but with a length of 1.0.
  ///
  /// Throws an [UnsupportedError] if the vector's length is 0.
  Vector2D get normalized {
    final len = length;
    if (len == 0) {
      throw UnsupportedError('Cannot normalize a zero-length vector');
    }
    return this / len;
  }

  /// Returns a normalized vector if possible, otherwise returns zero vector.
  Vector2D get normalizedOrZero {
    final len = length;
    return len > 0 ? this / len : Vector2D.zero;
  }

  /// Returns a new vector with the same direction but limited to a maximum length.
  Vector2D limit(double maxLength) {
    final len = length;
    return len > maxLength ? (this / len) * maxLength : this;
  }

  /// Returns a new vector that represents this vector scaled by [factor].
  Vector2D operator *(double factor) => Vector2D(x * factor, y * factor);

  /// Returns a new vector that represents this vector divided by [divisor].
  Vector2D operator /(double divisor) => Vector2D(x / divisor, y / divisor);

  /// Returns a new vector that is the sum of this vector and [other].
  Vector2D operator +(Vector2D other) => Vector2D(x + other.x, y + other.y);

  /// Returns a new vector that is the difference of this vector and [other].
  Vector2D operator -(Vector2D other) => Vector2D(x - other.x, y - other.y);

  /// Returns a new vector with the absolute value of each component.
  Vector2D abs() => Vector2D(x.abs(), y.abs());

  /// Returns the dot product of this vector and [other].
  double dot(Vector2D other) => x * other.x + y * other.y;

  /// Returns the angle between this vector and the positive x-axis in radians.
  double get angle => math.atan2(y, x);

  /// Returns the angle between this vector and [other] in radians.
  double angleBetween(Vector2D other) {
    if (lengthSquared == 0 || other.lengthSquared == 0) {
      throw UnsupportedError('Cannot calculate angle with zero-length vector');
    }

    final dot = this.dot(other);
    final len = length * other.length;

    // Clamp the value to avoid floating point errors
    final value = (dot / len).clamp(-1.0, 1.0);
    return math.acos(value);
  }

  /// Converts the vector to an Offset.
  Offset toOffset() => Offset(x, y);

  /// Converts the vector to a normalized Offset.
  ///
  /// If the vector has zero length, returns Offset.zero.
  Offset toNormalizedOffset() {
    if (!canNormalize) return Offset.zero;
    final normalized = normalizedOrZero;
    return Offset(normalized.x, normalized.y);
  }

  @override
  String toString() => 'Vector2D($x, $y)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vector2D && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
