import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wamdaa/app/providers/all_app_provider.dart';
import '../app/providers/current_profile_provider.dart';
import '../models/alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/ble_screen/providers/providers.dart';

final bluetoothServiceProvider = Provider<ESP32BluetoothService>((ref) {
  return ESP32BluetoothService();
});

class ESP32BluetoothService {
  // UUIDs - must match ESP32 code
  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String ALERT_CHAR_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String VOLTAGE_CHAR_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a9";
  static const String LED_TEST_CHAR_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26aa";
  static const String STATUS_CHAR_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26ab";

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _alertCharacteristic;
  BluetoothCharacteristic? _voltageCharacteristic;
  BluetoothCharacteristic? _ledTestCharacteristic;
  BluetoothCharacteristic? _statusCharacteristic;

  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  final StreamController<double> _voltageController =
      StreamController<double>.broadcast();

  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  Stream<double> get voltageStream => _voltageController.stream;

  bool get isConnected => _connectedDevice != null;

  // Scan for ESP32 device
  Future<List<BluetoothDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    List<BluetoothDevice> devices = [];

    // Check if Bluetooth is on
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception("Bluetooth not supported by this device");
    }

    // Start scanning
    await FlutterBluePlus.startScan(timeout: timeout);

    // Listen to scan results
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName.contains("ESP32_Alert") ||
            r.advertisementData.serviceUuids.contains(SERVICE_UUID)) {
          if (!devices.contains(r.device)) {
            devices.add(r.device);
          }
        }
      }
    });

    await Future.delayed(timeout);
    await FlutterBluePlus.stopScan();
    await subscription.cancel();
    return devices;
  }

  // Connect to ESP32
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: true,
        mtu: null,
        license: License.free,
      );
      _connectedDevice = device;

      // Wait until connection is confirmed
      await device.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .first;

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        print(service.uuid.toString());
        if (service.uuid.toString().toLowerCase() ==
            SERVICE_UUID.toLowerCase()) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            String charUuid = characteristic.uuid.toString().toLowerCase();

            if (charUuid == ALERT_CHAR_UUID.toLowerCase()) {
              _alertCharacteristic = characteristic;
            } else if (charUuid == VOLTAGE_CHAR_UUID.toLowerCase()) {
              _voltageCharacteristic = characteristic;
              // Subscribe to voltage updates
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                if (value.isNotEmpty) {
                  double voltage = _parseVoltage(value);
                  _voltageController.add(voltage);
                  globalContainer.read(voltageValueProvider.notifier).state =
                      voltage;
                }
              });
            } else if (charUuid == LED_TEST_CHAR_UUID.toLowerCase()) {
              _ledTestCharacteristic = characteristic;
            } else if (charUuid == STATUS_CHAR_UUID.toLowerCase()) {
              _statusCharacteristic = characteristic;
            }
          }
        }
      }

      _connectionStateController.add(true);

      // Listen for disconnection
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  // Disconnect from ESP32
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _connectedDevice = null;
    _alertCharacteristic = null;
    _voltageCharacteristic = null;
    _ledTestCharacteristic = null;
    _statusCharacteristic = null;
    _connectionStateController.add(false);
  }

  // Send alerts to ESP32
  Future<bool> syncAlerts(List<Alert> alerts) async {
    if (_alertCharacteristic == null) {
      print('Alert characteristic not available');
      return false;
    }
    try {
      List<Map<String, dynamic>> alertsData = alerts.map((alert) {
        return {
          'label': alert.label,
          'hour': alert.hour,
          'minute': alert.minute,
          'days': _daysMapToInt(alert.daysMap),
          'enabled': alert.enabled ? 1 : 0,
        };
      }).toList();

      String jsonData = jsonEncode({'alerts': alertsData});
      List<int> bytes = utf8.encode(jsonData);

      // Send in chunks if data is large (BLE MTU limit is typically 20-512 bytes)
      const int chunkSize = 15;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        List<int> chunk = bytes.sublist(i, end);

        await _alertCharacteristic!.write(chunk, withoutResponse: false);
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Small delay between chunks
      }

      // Send end marker
      await _alertCharacteristic!.write([0xFF, 0xFF], withoutResponse: false);

      print('Alerts synced successfully');
      return true;
    } catch (e) {
      print('Error syncing alerts: $e');
      return false;
    }
  }

  // Test LED
  Future<bool> testLED() async {
    if (_ledTestCharacteristic == null) {
      print('LED test characteristic not available');
      return false;
    }

    try {
      await _ledTestCharacteristic!.write([0x01], withoutResponse: false);
      final currentProfile = globalContainer.read(currentUserProfileProvider);
      syncAlerts(currentProfile?.alerts ?? []);
      return true;
    } catch (e) {
      print('Error testing LED: $e');
      return false;
    }
  }

  // Read voltage (one-time read)
  Future<double?> readVoltage() async {
    if (_voltageCharacteristic == null) {
      print('Voltage characteristic not available');
      return null;
    }

    try {
      List<int> value = await _voltageCharacteristic!.read();
      return _parseVoltage(value);
    } catch (e) {
      print('Error reading voltage: $e');
      return null;
    }
  }

  double _parseVoltage(List<int> value) {
    if (value.length >= 4) {
      // Parse as float (4 bytes)
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(value));
      return byteData.getFloat32(0, Endian.little);
    }
    return 0.0;
  }

  // Convert daysMap to integer bitmask
  int _daysMapToInt(Map daysMap) {
    int days = 0;
    if (daysMap['monday'] == true) days |= (1 << 0);
    if (daysMap['tuesday'] == true) days |= (1 << 1);
    if (daysMap['wednesday'] == true) days |= (1 << 2);
    if (daysMap['thursday'] == true) days |= (1 << 3);
    if (daysMap['friday'] == true) days |= (1 << 4);
    if (daysMap['saturday'] == true) days |= (1 << 5);
    if (daysMap['sunday'] == true) days |= (1 << 6);
    return days;
  }

  // Get ESP32 status
  Future<String?> getStatus() async {
    if (_statusCharacteristic == null) {
      print('Status characteristic not available');
      return null;
    }

    try {
      List<int> value = await _statusCharacteristic!.read();
      return utf8.decode(value);
    } catch (e) {
      print('Error reading status: $e');
      return null;
    }
  }

  void dispose() {
    _connectionStateController.close();
    _voltageController.close();
  }
}
