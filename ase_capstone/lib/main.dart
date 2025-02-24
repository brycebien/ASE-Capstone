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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      title: 'Campus Compass',
      home: const AuthPage(),
      routes: {
        '/map': (context) => MapPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
