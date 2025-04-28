import 'package:ase_capstone/themes/dark_theme.dart';
import 'package:ase_capstone/themes/light_theme.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  final FirestoreService _firestoreService = FirestoreService();

  ThemeData get themeData => _themeData;

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  Future<ThemeData> getTheme({required mode}) async {
    final User user = FirebaseAuth.instance.currentUser!;

    final Map<String, dynamic> userTheme =
        await _firestoreService.getUserTheme(userId: user.uid, themeName: mode);

    if (userTheme.isEmpty) {
      return isDarkMode ? darkTheme : lightTheme;
    }

    final primaryColor = Color(userTheme['primaryColor'] as int);
    final secondaryColor = Color(userTheme['secondaryColor'] as int);
    final tertiaryColor = Color(userTheme['tertiaryColor'] as int);
    final surfaceColor = Color(userTheme['surfaceColor'] as int);
    final appBarBackgroundColor =
        Color(userTheme['appBarBackgroundColor'] as int);
    final appBarForegroundColor =
        Color(userTheme['appBarForegroundColor'] as int);
    final appBarTitleColor = Color(userTheme['appBarTitleColor'] as int);
    final brightness =
        userTheme['brightness'] == 'Dark' ? Brightness.dark : Brightness.light;

    final userThemeData = ThemeData(
      brightness: brightness,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: appBarTitleColor,
        ),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        onSurface: Colors.white,
        // main background color
        surface: surfaceColor,

        // primary color (app bar, buttons)
        primary: primaryColor,

        // hint text (such as forgot password)
        secondary: secondaryColor,

        // Things like button text (text on primary color)
        tertiary: tertiaryColor,
      ),
    );

    return userThemeData;
  }

  void setTheme() async {
    _themeData = await getTheme(mode: isDarkMode ? 'Dark' : 'Light');
    notifyListeners();
  }

  void toggleTheme(isDark) {
    // final isDark = _themeData.brightness == Brightness.dark;
    // _isDarkMode = !isDark;
    _isDarkMode = isDark;
    setTheme();
    notifyListeners();
  }
}
