import 'dart:io';

import 'package:flutter/material.dart';
import 'providers/auth_provider/auth_provider.dart';
import 'providers/generic_provider/api_client.dart';
import 'screens/auth_screens/login_screen.dart';
import 'widgets/main_navbar_widget.dart';
import 'helpers/dev_http_override.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = DevHttpOverrides();

  final authProvider = AuthProvider();

  final isAuthenticated = await authProvider.restoreSession();

  ApiClient.setAuthenticationFailureHandler(() async {
    final navigator = MyApp.navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(title: "Login", sessionExpired: true),
      ),
      (route) => false,
    );
  });

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniRay (Mobile)',

      navigatorKey: navigatorKey,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 93, 12, 94),
        ),
      ),

      home: isAuthenticated
          ? const MainNavbarWidget()
          : const LoginScreen(key: ValueKey("main"), title: ""),
    );
  }
}
