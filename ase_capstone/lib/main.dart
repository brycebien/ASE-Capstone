import 'package:ase_capstone/pages/auth_page.dart';
import 'package:ase_capstone/pages/create_university_page.dart';
import 'package:ase_capstone/pages/development_page.dart';
import 'package:ase_capstone/pages/edit_university_page.dart';
import 'package:ase_capstone/pages/event_reminders_page.dart';
import 'package:ase_capstone/pages/forgot_password_page.dart';
import 'package:ase_capstone/pages/map_page.dart';
import 'package:ase_capstone/pages/schedule_page.dart';
import 'package:ase_capstone/pages/settings_page.dart';
import 'package:ase_capstone/pages/profile_page.dart';
import 'package:ase_capstone/pages/inbox_page.dart';
import 'package:ase_capstone/pages/event_page.dart';
import 'package:ase_capstone/pages/theme_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:ase_capstone/themes/light_theme.dart';
import 'package:ase_capstone/themes/dark_theme.dart';
import 'package:ase_capstone/pages/resources_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

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
        '/forgot-password': (context) => ForgotPassword(),
        '/auth': (context) => const AuthPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => SettingsPage(
              toggleTheme: toggleTheme,
              isDarkMode: isDarkMode,
            ),
        '/map': (context) => const MapPage(),
        '/schedule': (context) => SchedulePage(),
        '/resources': (context) => ResourcesPage(),
        '/inbox': (context) => InboxPage(),
        '/events': (context) => const EventPage(),
        '/development-page': (context) => const DevelopmentPage(),
        '/edit-university': (context) => const EditUniversityPage(),
        '/create-university': (context) => const CreateUniversityPage(),
        '/reminders': (context) => const EventRemindersPage(),
        '/theme-selection': (context) => ThemeSelection(),
      },
    );
  }
}
