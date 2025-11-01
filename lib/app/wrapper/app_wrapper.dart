import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/auth_state.dart';
import '../../screens/ble_screen/providers/providers.dart';
import '../../services/auth_controller.dart';
import '../../services/ble_service.dart';
import '../providers/all_app_provider.dart';

class AuthenticatedWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AuthenticatedWrapper({super.key, required this.child});
  @override
  ConsumerState<AuthenticatedWrapper> createState() =>
      _AuthenticatedWrapperState();
}

class _AuthenticatedWrapperState extends ConsumerState<AuthenticatedWrapper> {
  bool _listenerSet = false;

  List<BluetoothDevice> allDevices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
      FlutterBluePlus.events.onConnectionStateChanged.listen((event) async{
        globalContainer.read(bLEConnectedProvider.notifier).state =
            event.connectionState == BluetoothConnectionState.connected;

        await event.device.connectionState
            .where((state) => state == BluetoothConnectionState.connected)
            .first;

        if(event.connectionState == BluetoothConnectionState.connected) {
          print('################## Connected to device');
          globalContainer.read(bluetoothServiceProvider).discoverServices(event.device);
        }
      });

      findDevice();
    });
  }

  findDevice() async {
    final _bluetoothService = ref.read(bluetoothServiceProvider);
    try {
      List<BluetoothDevice> devices = await _bluetoothService.scanForDevices();
      allDevices = devices;
      if (allDevices.isNotEmpty) {
        allDevices.forEach((device) async {
          if (device.advName == 'ESP32_Alert_System') {
            await _bluetoothService.connectToDevice(device);
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    final _bluetoothService = ref.read(bluetoothServiceProvider);
    _bluetoothService.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      await Permission.location.request();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // We ensure this listener is added only once
    if (_listenerSet) return;
    _listenerSet = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalContainer.listen<AuthState>(authControllerProvider, (
        previous,
        next,
      ) {
        final router = GoRouter.of(context);
        final currentLocation = router.state.uri.toString();
        String? targetRoute;

        switch (next) {
          case AuthInitial():
          case AuthLoading():
            targetRoute = '/loading';
            break;

          case AuthAuthenticated():
            targetRoute = '/home';
            break;

          case AuthUnauthenticated():
            targetRoute = '/login';
            break;

          case AuthError():
            targetRoute = '/error';
            break;
        }

        if (targetRoute != null && currentLocation != targetRoute) {
          router.go(targetRoute);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
