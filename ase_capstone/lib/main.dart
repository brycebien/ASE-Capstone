import 'package:ase_capstone/models/theme_notifier.dart';
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
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:ase_capstone/themes/dark_theme.dart';
import 'package:ase_capstone/pages/resources_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Return ChangeNotifierProvider to provide ThemeNotifier to the app
    return ChangeNotifierProvider(
        create: (context) => ThemeNotifier(darkTheme),
        builder: (context, child) {
          final provider = Provider.of<ThemeNotifier>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: provider.themeData,
            title: 'Campus Compass',
            home: const AuthPage(),
            routes: {
              '/forgot-password': (context) => ForgotPassword(),
              '/auth': (context) => const AuthPage(),
              '/profile': (context) => const ProfilePage(),
              '/settings': (context) => SettingsPage(),
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
        });
  }
}
