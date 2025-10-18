import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/set_alert_screen.dart';
import 'screens/view_alerts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();      // ✅ must come first
  await Firebase.initializeApp();                 // ✅ initialize Firebase
  runApp(const WamdaApp());                       // ✅ then run the app
}

class WamdaApp extends StatelessWidget {
  const WamdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/settings': (_) => const SettingsScreen(), // add patterns
        '/setalert': (_) => const SetAlertScreen(), //
        '/alerts': (_) => const ViewAlertsScreen(), // <--- route added change view alarm to manage
      },
    );
  }
}
