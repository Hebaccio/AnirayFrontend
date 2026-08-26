import 'package:aniray_desktop/providers/auth_provider/auth_provider.dart';
import 'package:aniray_desktop/providers/generic_provider/api_client.dart';
import 'package:aniray_desktop/screens/auth_screens/login_screen.dart';
import 'package:aniray_desktop/widgets/main_sidebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize desktop window manager.
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    minimumSize: Size(1200, 800),
    size: Size(1440, 900),
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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
      title: 'AniRay (Desktop)',

      navigatorKey: navigatorKey,

      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 93, 12, 94),
        ),
      ),

      home: isAuthenticated
          ? const MainSidebarWidget()
          : const LoginScreen(key: ValueKey("main"), title: ""),
    );
  }
}
