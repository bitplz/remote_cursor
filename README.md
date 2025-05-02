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

![RemoteCursor Demo](https://example.com/screenshot1.png)
![Gyroscope Control](https://example.com/screenshot2.png)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  remote_cursor: ^1.0.0
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
final trackpadController = TrackpadController.instance;

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
final gyroController = GyroController.instance;

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

## Example

```dart
import 'package:flutter/material.dart';
import 'package:remote_cursor/remote_cursor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize WebSocket service
  await RemoteCursor.init(
    webSocketConfig: WebSocketConfig(ip: '192.168.1.100', port: 8080),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Remote Pointer Example')),
        body: const MouseControllerPage(),
      ),
    );
  }
}

class MouseControllerPage extends StatefulWidget {
  const MouseControllerPage({Key? key}) : super(key: key);

  @override
  _MouseControllerPageState createState() => _MouseControllerPageState();
}

class _MouseControllerPageState extends State<MouseControllerPage> {
  bool _useGyro = false;
  final trackpadController = TrackpadController.instance;
  final gyroController = GyroController.instance;

  @override
  void dispose() {
    RemoteCursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Control type toggle
        SwitchListTile(
          title: Text(_useGyro ? 'Gyroscope Control' : 'Trackpad Control'),
          value: _useGyro,
          onChanged: (value) {
            setState(() {
              _useGyro = value;
              if (_useGyro) {
                gyroController.activate();
              } else {
                gyroController.deactivate();
              }
            });
          },
        ),
        
        // Control area
        Expanded(
          child: _useGyro 
            ? const Center(child: Text('Move device to control cursor'))
            : GestureDetector(
                onPanUpdate: (details) {
                  trackpadController.onDrag(details.delta);
                },
                onTap: () => trackpadController.sendClick(),
                onDoubleTap: () => trackpadController.sendDoubleClick(),
                onLongPress: () => trackpadController.sendRightClick(),
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(child: Text('Trackpad Area')),
                ),
              ),
        ),
      ],
    );
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
