import 'package:flutter/material.dart';
import 'package:remote_cursor/remote_cursor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RemoteCursor.init(
    webSocketConfig: WebSocketConfig(ip: '192.168.1.100', port: 44213) //Your ip address:port
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Cursor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MouseControllerPage(),
    );
  }
}


class MouseControllerPage  extends StatefulWidget {
  const MouseControllerPage ({super.key});

  @override
  State<MouseControllerPage> createState() => _MouseControllerPageState();
}

class _MouseControllerPageState extends State<MouseControllerPage > {

  final trackpadController = RemoteCursor.trackpadController;
  final gyroController = RemoteCursor.gyroController;
  final remoteConnection = RemoteCursor.remoteCursorConnection;

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: remoteConnection.isConnected?
          Text('${remoteConnection.isConnected? "Connected": "Disconnected"} : ${remoteConnection.currentUrl}', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 12),):
          Text(!remoteConnection.isConnected? "Unable to establish connection\n(${remoteConnection.currentUrl})": "", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 14)),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.touch_app), text: 'Trackpad'),
              Tab(
                icon: Icon(Icons.edgesensor_high_rounded),
                text: 'GyroSensor',
              ),
            ],
          ),
        ),
        body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [_buildTrackpadView(), _buildGyroView()]),
      ),
    );
  }

  _buildTrackpadView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: GestureDetector(
              onPanUpdate: (details) {
                trackpadController.onDrag(details.delta);
              },
              onTap: () => trackpadController.sendClick(),
              onDoubleTap: () => trackpadController.sendDoubleClick(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Touch and Drag',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8,),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => trackpadController.sendClick(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Left Click',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2,),
                Expanded(
                  child: InkWell(
                    onTap: () => trackpadController.sendRightClick(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Right Click',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildGyroView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Expanded(
              flex: 10,
              child: StreamBuilder(
                stream: gyroController.gyroDataStream,
                builder: (context, event) {
                  if(!event.hasData || event.hasError) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.blueGrey.shade400,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Center(
                        child: Text(
                          'Hit activate to start using',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return _buildDefaultVisualization(Offset(event.data!.x, event.data!.y));
                },
              )
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => gyroController.calibrate(),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Center(
                  child: Text(
                    'Calibrate',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => gyroController.activate(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Activate\nor\nResume',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2,),
                Expanded(
                  child: InkWell(
                    onTap: () => gyroController.pause(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Pause',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultVisualization(Offset gyroData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade400,
          borderRadius: BorderRadius.circular(12)
      ),
      height: 200,
      child: Stack(
        children: [
          // Center point indicator
          Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Gyroscope position indicator
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: Matrix4.translationValues(
                gyroData.dx * 50, // Scale for visualization
                gyroData.dy * 50, // Scale for visualization
                0,
              ),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Display gyroscope values
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              'X: ${gyroData.dx.toStringAsFixed(2)}, Y: ${gyroData.dy.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Status indicator
          Positioned(
            top: 16,
            right: 16,
            child: Text(
              gyroController.isActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}


