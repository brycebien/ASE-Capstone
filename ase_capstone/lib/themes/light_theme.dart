import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    // app bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 248, 120, 81),

      // items on app bar like settings or logout
      foregroundColor: Color.fromARGB(255, 54, 54, 54),

      // title on app bar
      titleTextStyle: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 54, 54, 54),
      ),
    ),
    colorScheme: ColorScheme.light(
      // main background color
      surface: const Color.fromARGB(255, 245, 184, 165),

      // primary color (app bar, buttons)
      primary: const Color.fromARGB(255, 248, 120, 81),

      // hint text (such as forgot password)
      secondary: Colors.grey[600]!,

      // Things like button text (text on primary color)
      tertiary: const Color.fromARGB(255, 54, 54, 54),
    ));
