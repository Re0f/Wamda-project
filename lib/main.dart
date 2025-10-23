import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app/providers/all_app_provider.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(
        () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await EasyLocalization.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
      };

      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Center(
          child: Text(
            "Something went wrong 😢",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
      };

      runApp(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: UncontrolledProviderScope(
            container: globalContainer,
            child: App(),
          ),
        ),
      );
    },
        (error, stack) {
      print("Uncaught async error: $error");
      print(stack);
    },
  );
}
