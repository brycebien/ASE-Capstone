import 'package:ase_capstone/pages/auth_page.dart';
import 'package:ase_capstone/pages/map_page.dart';
import 'package:ase_capstone/pages/settings_page.dart'; // Import the settings page
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Campus Compass',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: AuthPage(),
          routes: {
            '/map': (context) => MapPage(),
            '/settings': (context) => SettingsPage(),
          },
        );
      },
    );
  }
}
