# RemoteCursor

[![Pub Version](https://img.shields.io/pub/v/remote_cursor.svg)](https://pub.dev/packages/remote_cursor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful Flutter package that transforms your mobile device into a wireless mouse/trackpad controller. Control your computer cursor with precision using touch gestures or device gyroscope movements via WebSocket communication.

## Features

- **Dual Control Methods**: Use your device as a touchpad or motion-controlled pointer
- **Precise Tracking**: Advanced algorithms for smooth cursor movement
- **Customizable Sensitivity**: Fine-tune controls for your preferences
- **WebSocket Communication**: Low-latency connection to your computer
- **Gesture Support**: Click, right-click, double-click actions
- **Configuration Options**: Extensive parameters to customize behavior

## Gyroscope Control Demo
![RemoteCursor Demo](https://github.com/bitplz/remote_cursor/blob/master/example/gyro-demo.gif)

## Trackpad Control Demo
![Gyroscope Control](https://github.com/bitplz/remote_cursor/blob/master/example/trackpad-demo.gif)

## Supported Gestures

| Gesture | Description | JSON Value | Status |
|---------|-------------|------------|--------|
| Move | Basic cursor movement | `"move"` | ✅ Supported |
| Click | Left mouse button click | `"click"` | ✅ Supported |
| Double Click | Double left mouse button click | `"double_click"` | ✅ Supported |
| Right Click | Right mouse button click | `"right_click"` | ✅ Supported |
| Vertical Scroll | Scroll up and down | `"scroll_vertical"` | 🔄 Coming soon |
| Horizontal Scroll | Scroll left and right | `"scroll_horizontal"` | 🔄 Coming soon |
| Middle Click | Middle mouse button click | `"middle_click"` | 🔄 Coming soon |
| Drag Start | Begin drag operation | `"drag_start"` | 🔄 Coming soon |
| Drag Move | Continue drag operation | `"drag_move"` | 🔄 Coming soon |
| Drag End | End drag operation | `"drag_end"` | 🔄 Coming soon |
| Pinch Zoom | Zoom in/out using pinch gesture | `"pinch_zoom"` | 🔄 Coming soon |
| Swipe | Quick directional gestures | `"swipe_left"`, `"swipe_right"`, etc. | 🔄 Coming soon |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  remote_cursor: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the Service

```dart
import 'package:remote_cursor/remote_cursor.dart';

// Initialize with WebSocket configuration
await RemoteCursor.init(
  webSocketConfig: WebSocketConfig(
    ip: '192.168.1.100',  // Your computer's IP address
    port: 8080,           // WebSocket server port
  ),
);
```

### 2. Use Trackpad Controller


```dart
// Get the singleton instance
final trackpadController = RemoteCursor.trackpadController;

// In your GestureDetector
GestureDetector(
  onPanUpdate: (details) {
    trackpadController.onDrag(details.delta);
  },
  onTap: () {
    trackpadController.sendClick();
  },
  onDoubleTap: () {
    trackpadController.sendDoubleClick();
  },
  onLongPress: () {
    trackpadController.sendRightClick();
  },
  child: Container(
    color: Colors.grey[200],
    height: 300,
    width: double.infinity,
    child: Center(child: Text('Trackpad Area')),
  ),
);
```

### 3. Use Gyroscope Controller

```dart
// Get the singleton instance
final gyroController = RemoteCursor.gyroController;

// Activate gyroscope control
gyroController.activate();

// Deactivate when not needed
gyroController.deactivate();

// Pause when not needed
gyroController.pause();

// Listen to gyroscope data
gyroController.gyroDataStream.listen((vector) {
  // Vector contains processed gyro data if needed
  print('Gyro data: $vector');
});
```

## Server Setup

This package requires a WebSocket server running on your computer to receive mouse commands. You can find example server implementations in:

- [Python server example](https://github.com/bitplz/remote_cursor/blob/master/example/server/remote_cursor_server.py)

## Advanced Configuration

### Trackpad Configuration

```dart
// Create custom trackpad configuration
final customTrackpadConfig = TrackpadConfig(
  horizontalSensitivity: 1.5,
  verticalSensitivity: 1.2,
  accelerationCurve: 1.8,
  // More parameters...
);

// Initialize controller with custom config
final trackpadController = TrackpadController(config: customTrackpadConfig);
//
//or
//
final trackpadController = RemoteCursor.trackpadController;
trackpadController.initConfig(config: customTrackpadConfig);
```

### Gyroscope Configuration

```dart
// Create custom gyroscope configuration
final customGyroConfig = GyroConfig(
  deadZone: 0.05,
  smoothingFactor: 0.7,
  horizontalSensitivity: 1.3,
  verticalSensitivity: 1.0,
  // More parameters...
);

// Initialize controller with custom config
final gyroController = GyroController(config: customGyroConfig);
//
//or
//
final gyroController = RemoteCursor.gyroController;
gyroController.initConfig(config: customTrackpadConfig);
```

## API Reference

### Core Classes

| Class | Description |
|-------|-------------|
| `RemoteCursor` | Service locator for dependency management |
| `RemoteCursorConnection` | WebSocket connection management |
| `TrackpadController` | Handles touch input for trackpad functionality |
| `GyroController` | Processes gyroscope data for motion control |
| `WebSocketConfig` | Configuration for WebSocket connection |
| `TrackpadConfig` | Configuration parameters for trackpad behavior |
| `GyroConfig` | Configuration parameters for gyroscope behavior |

### TrackpadController

| Method | Description |
|--------|-------------|
| `onDrag(Offset delta)` | Processes drag movement |
| `sendClick()` | Sends a left-click action |
| `sendDoubleClick()` | Sends a double-click action |
| `sendRightClick()` | Sends a right-click action |
| `sendCustomData(Map<String, dynamic> data)` | Sends custom data to the server |
| `setSensitivity(double value)` | Sets overall sensitivity multiplier |

### GyroController

| Method | Description |
|--------|-------------|
| `activate()` | Starts gyroscope tracking |
| `deactivate()` | Stops gyroscope tracking |
| `pause()` | Temporarily pauses tracking |
| `calibrate()` | Calibrates gyroscope to adjust for drift |
| `reset()` | Resets all gyroscope data and state |
| `sendCustomData(Map<String, dynamic> data)` | Sends custom data to the server |

### RemoteCursorConnection

| Method | Description |
|--------|-------------|
| `connect(String url)` | Connects to WebSocket server |
| `disconnect()` | Disconnects from server |
| `sendMessage(MouseActionConfig mouseActionConfig)` | Sends standardized action |
| `sendCustomMessage(Map<String, dynamic> message)` | Sends custom message |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
