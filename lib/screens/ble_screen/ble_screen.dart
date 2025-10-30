// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../app/providers/current_profile_provider.dart';
// import '../../services/ble_service.dart';
//
// class ESP32ControlPage extends ConsumerStatefulWidget {
//   const ESP32ControlPage({super.key});
//   @override
//   ConsumerState createState() => _ESP32ControlPageState();
// }
//
// class _ESP32ControlPageState extends ConsumerState<ESP32ControlPage> {
//
//
//   Future<void> _syncAlerts(alerts) async {
//     setState(() {
//       _statusMessage = 'Syncing alerts...';
//     });
//
//     bool success = await _bluetoothService.syncAlerts(alerts);
//
//     setState(() {
//       _statusMessage = success ? 'Alerts synced' : 'Sync failed';
//     });
//
//     _showSnackBar(
//       success ? 'Alerts synced successfully' : 'Failed to sync alerts',
//       isError: !success,
//     );
//   }
//
//   Future<void> _testLED() async {
//     setState(() {
//       _statusMessage = 'Testing LED...';
//     });
//
//     bool success = await _bluetoothService.testLED();
//
//     setState(() {
//       _statusMessage = success ? 'LED test sent' : 'LED test failed';
//     });
//
//     _showSnackBar(
//       success ? 'LED test command sent' : 'Failed to test LED',
//       isError: !success,
//     );
//   }
//
//   Future<void> _readVoltage() async {
//     double? voltage = await _bluetoothService.readVoltage();
//     if (voltage != null) {
//       setState(() {
//         _voltage = voltage;
//       });
//       _showSnackBar('Voltage: ${voltage.toStringAsFixed(2)}V');
//     } else {
//       _showSnackBar('Failed to read voltage', isError: true);
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentProfile = ref.watch(currentUserProfileProvider);
//     final _alerts = currentProfile?.alerts ?? [];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ESP32 Control'),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
//             ),
//             onPressed: _isConnected ? _disconnect : _scanDevices,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Connection Status Card
//             Card(
//               color: _isConnected ? Colors.green[50] : Colors.grey[200],
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Icon(
//                       _isConnected
//                           ? Icons.bluetooth_connected
//                           : Icons.bluetooth_disabled,
//                       size: 48,
//                       color: _isConnected ? Colors.green : Colors.grey,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       _statusMessage,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//
//             // Voltage Display
//             if (_isConnected)
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Voltage Monitor',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '${_voltage.toStringAsFixed(2)} V',
//                         style: TextStyle(fontSize: 32, color: Colors.blue),
//                       ),
//                       SizedBox(height: 8),
//                       ElevatedButton(
//                         onPressed: _readVoltage,
//                         child: Text('Refresh Voltage'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//             SizedBox(height: 16),
//
//             // Action Buttons
//             if (_isConnected) ...[
//               ElevatedButton.icon(
//                 onPressed: (){
//                   _syncAlerts(_alerts);
//                 },
//                 icon: Icon(Icons.sync),
//                 label: Text('Sync Alerts (${_alerts.length})'),
//                 style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
//               ),
//               SizedBox(height: 8),
//               ElevatedButton.icon(
//                 onPressed: _testLED,
//                 icon: Icon(Icons.lightbulb),
//                 label: Text('Test LED'),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.all(16),
//                   backgroundColor: Colors.orange,
//                 ),
//               ),
//             ] else ...[
//               ElevatedButton.icon(
//                 onPressed: _isScanning ? null : _scanDevices,
//                 icon: _isScanning
//                     ? SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : Icon(Icons.search),
//                 label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
//                 style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
//               ),
//             ],
//
//             SizedBox(height: 16),
//
//             // Device List
//             if (_devices.isNotEmpty && !_isConnected) ...[
//               Text(
//                 'Available Devices:',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _devices.length,
//                   itemBuilder: (context, index) {
//                     BluetoothDevice device = _devices[index];
//                     return Card(
//                       child: ListTile(
//                         leading: Icon(Icons.bluetooth),
//                         title: Text(
//                           device.platformName.isEmpty
//                               ? 'Unknown Device'
//                               : device.platformName,
//                         ),
//                         subtitle: Text(device.remoteId.toString()),
//                         trailing: ElevatedButton(
//                           onPressed: () => _connectToDevice(device),
//                           child: Text('Connect'),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
