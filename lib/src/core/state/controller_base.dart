// import 'package:get/get.dart';
// import 'remote_cursor_connection_service.dart';
//
// /// Base controller class that provides common functionality for all controllers
// abstract class ControllerBase extends GetxController {
//   /// WebSocket service for sending/receiving data
//   final WebSocketService webSocketService;
//
//   /// Whether the controller is currently active
//   final RxBool isActive = false.obs;
//
//   /// Initialize the controller with required dependencies
//   ControllerBase({required this.webSocketService});
//
//   /// Start the controller's functionality
//   void start() {
//     if (!isActive.value) {
//       isActive.value = true;
//       onStart();
//     }
//   }
//
//   /// Stop the controller's functionality
//   void stop() {
//     if (isActive.value) {
//       isActive.value = false;
//       onStop();
//     }
//   }
//
//   /// Toggle the controller's active state
//   void toggle() {
//     isActive.value ? stop() : start();
//   }
//
//   /// Additional actions to perform when stopping
//   void onStop();
//
//   @override
//   void onClose() {
//     stop();
//     super.onClose();
//   }
// }
