import 'package:ase_capstone/pages/auth_page.dart';
import 'package:ase_capstone/pages/map_page.dart';
import 'package:ase_capstone/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:ase_capstone/themes/light_theme.dart';
import 'package:ase_capstone/themes/dark_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme(bool mode) {
    setState(() {
      isDarkMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      title: 'Campus Compass',
      home: const AuthPage(),
      routes: {
        '/map': (context) => MapPage(),
        '/settings': (context) => SettingsPage(
              toggleTheme: toggleTheme,
              isDarkMode: isDarkMode,
            ),
      },
    );
  }
}
