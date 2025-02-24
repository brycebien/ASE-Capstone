import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
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
