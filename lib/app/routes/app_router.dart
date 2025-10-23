import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/add_new_alert/set_alert_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/login/forget_password.dart';
import '../../screens/login/loading_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/login/sign_up_screen.dart';
import '../../screens/login/signin_error_screen.dart';
import '../../screens/settings/settings_page.dart';
import '../wrapper/app_wrapper.dart';

final _rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final GlobalKey<NavigatorState> rootKey = ref.watch(
    _rootNavigatorKeyProvider,
  );

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/login',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AuthenticatedWrapper(child: child);
        },
        routes: [
          GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
          GoRoute(
            path: '/reset-password',
            builder: (context, state) => const ResetPasswordScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>  SettingsPage(),
          ),
          GoRoute(
            path: '/new-alert',
            builder: (context, state) =>  SetAlertScreen(),
          ),
          GoRoute(
            path: '/error',
            builder: (context, state) =>  SignInErrorScreen(),
          ),
          GoRoute(
            path: '/loading',
            builder: (context, state) =>  LoadingScreen(),
          ),
        ],
      ),
    ],
  );
});
