import 'package:ase_capstone/components/choose_color_input.dart';
import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/models/theme_notifier.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class ThemeSelection extends StatefulWidget {
  const ThemeSelection({super.key});

  @override
  State<ThemeSelection> createState() => _ThemeSelectionState();
}

class _ThemeSelectionState extends State<ThemeSelection> {
  final FirestoreService _firestoreService = FirestoreService();
  final User user = FirebaseAuth.instance.currentUser!;

  bool _isLoading = true;

  late String selectedTheme;

  // MAIN THEME DEFAULT COLORS
  late Color primaryColor;
  late Color secondaryColor;
  late Color tertiaryColor;
  late Color surfaceColor;

  // APP BAR THEME DEFAULT COLORS
  late Color appBarBackgroundColor;
  late Color appBarForegroundColor;
  late Color appBarTitleColor;

  @override
  void initState() {
    super.initState();
    _loadCurrentThemeColors();
    selectedTheme =
        Provider.of<ThemeNotifier>(context, listen: false).isDarkMode
            ? 'Dark'
            : 'Light';
  }

  void _loadCurrentThemeColors() async {
    final userTheme = await _firestoreService.getUserTheme(
      userId: user.uid,
      themeName: Provider.of<ThemeNotifier>(context, listen: false).isDarkMode
          ? 'Dark'
          : 'Light',
    );

    if (userTheme.isNotEmpty) {
      setState(() {
        primaryColor = Color(userTheme['primaryColor'] as int);
        secondaryColor = Color(userTheme['secondaryColor'] as int);
        tertiaryColor = Color(userTheme['tertiaryColor'] as int);
        surfaceColor = Color(userTheme['surfaceColor'] as int);
        appBarBackgroundColor =
            Color(userTheme['appBarBackgroundColor'] as int);
        appBarForegroundColor =
            Color(userTheme['appBarForegroundColor'] as int);
        appBarTitleColor = Color(userTheme['appBarTitleColor'] as int);
        _isLoading = false;
      });
    } else {
      setState(() {
        primaryColor = Color.fromARGB(255, 248, 120, 81);
        secondaryColor = Colors.grey[600]!;
        tertiaryColor = Color.fromARGB(255, 54, 54, 54);
        surfaceColor = Color.fromARGB(255, 54, 54, 54);
        appBarBackgroundColor = Color.fromARGB(255, 54, 54, 54);
        appBarForegroundColor = Color.fromARGB(255, 180, 180, 180);
        appBarTitleColor = Color.fromARGB(255, 180, 180, 180);
        _isLoading = false;
      });
    }
  }

  Future<Color?> _showColorPicker({required Color color}) async {
    Color? pickedColor = await showDialog<Color>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: (newColor) {
                  setState(() {
                    color = newColor;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Select'),
                onPressed: () {
                  Navigator.of(context).pop(color);
                },
              ),
            ],
          );
        });
    return pickedColor;
  }

  Future<void> _saveColorTheme() async {
    // SAVE SELECTED THEME COLORS TO DATABASE

    final userTheme = {
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'tertiaryColor': tertiaryColor.toARGB32(),
      'surfaceColor': surfaceColor.toARGB32(),
      'appBarBackgroundColor': appBarBackgroundColor.toARGB32(),
      'appBarForegroundColor': appBarForegroundColor.toARGB32(),
      'appBarTitleColor': appBarTitleColor.toARGB32(),
      'brightness': selectedTheme == 'Dark' ? 'dark' : 'light',
    };

    await _firestoreService.saveTheme(
      userId: user.uid,
      theme: userTheme,
      themeName: selectedTheme,
    );

    if (mounted) {
      Provider.of<ThemeNotifier>(context, listen: false).setTheme();
      Navigator.of(context).pop();
      Utils.displayMessage(
        context: context,
        message: 'Theme updated successfully!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: surfaceColor,
            appBar: AppBar(
              title: const Text('Edit Theme'),
              backgroundColor: appBarBackgroundColor,
              foregroundColor: appBarForegroundColor,
              titleTextStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: appBarTitleColor,
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: kIsWeb
                    ? EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width > 800
                            ? MediaQuery.of(context).size.width * .3
                            : 40,
                      )
                    : EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Editing Theme: ",
                          ),
                          // CHOOSE THEME TO EDIT
                          Text(selectedTheme),
                        ],
                      ),
                      Divider(
                        color: primaryColor,
                        thickness: 2,
                        height: 40,
                      ),
                      const Text(
                        'Main Color Theme:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 40),
                      // CHANGE THEME COLOR PICKERS
                      // PRIMARY
                      ChooseColorInput(
                        instructionText: 'Primary',
                        showColorPicker: _showColorPicker,
                        initialColor: primaryColor,
                        onColorChanged: (newColor) {
                          setState(() {
                            primaryColor = newColor;
                          });
                        },
                      ),
                      SizedBox(height: 40),

                      // SECONDARY
                      ChooseColorInput(
                        instructionText: 'Secondary',
                        showColorPicker: _showColorPicker,
                        initialColor: secondaryColor,
                        onColorChanged: (newColor) {
                          setState(() {
                            secondaryColor = newColor;
                          });
                        },
                      ),
                      SizedBox(height: 40),

                      // TERTIARY
                      ChooseColorInput(
                        instructionText: 'Tertiary',
                        showColorPicker: _showColorPicker,
                        initialColor: tertiaryColor,
                        onColorChanged: (newColor) {
                          setState(() {
                            tertiaryColor = newColor;
                          });
                        },
                      ),
                      SizedBox(height: 40),

                      // BACKGROUND (SURFACE)
                      ChooseColorInput(
                        instructionText: 'Background',
                        showColorPicker: _showColorPicker,
                        initialColor: surfaceColor,
                        onColorChanged: (newColor) {
                          setState(() {
                            surfaceColor = newColor;
                          });
                        },
                      ),
                      Divider(
                        color: primaryColor,
                        thickness: 2,
                        height: 40,
                      ),
                      const Text(
                        'App Bar Theme:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 40),
                      // APPBAR THEME
                      // APP BAR BACKGROUND COLOR
                      ChooseColorInput(
                        instructionText: 'App Bar Background',
                        showColorPicker: _showColorPicker,
                        initialColor: appBarBackgroundColor,
                        onColorChanged: (newColor) {
                          setState(() {
                            appBarBackgroundColor = newColor;
                          });
                        },
                      ),
                      SizedBox(height: 40),

                      // APP BAR FOREGROUND COLOR
                      ChooseColorInput(
                        instructionText: 'App Bar icons and actions',
                        showColorPicker: _showColorPicker,
                        initialColor: appBarForegroundColor,
                        onColorChanged: (newColor) {
                          setState(() {
                            appBarForegroundColor = newColor;
                          });
                        },
                      ),
                      SizedBox(height: 40),

                      // APP BAR TITLE COLOR
                      ChooseColorInput(
                        instructionText: 'App Bar title',
                        showColorPicker: _showColorPicker,
                        initialColor: appBarTitleColor,
                        onColorChanged: (newColor) {
                          setState(() {
                            appBarTitleColor = newColor;
                          });
                        },
                      ),
                      SizedBox(height: 80),
                      Center(
                        child: MyButton(
                          buttonText: 'Save',
                          onTap: _saveColorTheme,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
