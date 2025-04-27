import 'package:ase_capstone/components/choose_color_input.dart';
import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeSelection extends StatefulWidget {
  const ThemeSelection({super.key});

  @override
  State<ThemeSelection> createState() => _ThemeSelectionState();
}

class _ThemeSelectionState extends State<ThemeSelection> {
  final FirestoreService _firestoreService = FirestoreService();
  final User user = FirebaseAuth.instance.currentUser!;

  String selectedTheme = 'Dark';

  // MAIN THEME DEFAULT COLORS
  Color primaryColor = Color.fromARGB(255, 248, 120, 81);
  Color secondaryColor = Colors.grey[600]!;
  Color tertiaryColor = Color.fromARGB(255, 54, 54, 54);
  Color surfaceColor = Color.fromARGB(255, 54, 54, 54);

  // APP BAR THEME DEFAULT COLORS
  Color appBarBackgroundColor = Color.fromARGB(255, 54, 54, 54);
  Color appBarForegroundColor = Color.fromARGB(255, 180, 180, 180);
  Color appBarTitleColor = Color.fromARGB(255, 180, 180, 180);

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
    };

    await _firestoreService.saveTheme(
      userId: user.uid,
      theme: userTheme,
      themeName: selectedTheme,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      "Slect a theme to edit: ",
                    ),
                    // CHOOSE THEME TO EDIT
                    DropdownButton<String>(
                      value: selectedTheme,
                      items: <String>['Dark', 'Light']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTheme = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                Divider(
                  color: primaryColor,
                  thickness: 2,
                  height: 40,
                ),
                const Text(
                  'Main Color Theme:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
