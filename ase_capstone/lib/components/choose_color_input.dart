import 'package:flutter/material.dart';

class ChooseColorInput extends StatefulWidget {
  final String instructionText;
  final Function showColorPicker;
  final Color initialColor;
  final Function onColorChanged;
  const ChooseColorInput({
    super.key,
    required this.instructionText,
    required this.showColorPicker,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ChooseColorInput> createState() => _ChooseColorInputState();
}

class _ChooseColorInputState extends State<ChooseColorInput> {
  late Color initialColor;
  @override
  void initState() {
    super.initState();
    initialColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0, // Adds spacing between the children
      runSpacing: 10.0, // Adds spacing between rows when wrapping
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${widget.instructionText} Color: '),
        TextButton(
          onPressed: () async {
            final Color? selectedColor =
                await widget.showColorPicker(color: initialColor);
            if (selectedColor != null) {
              widget.onColorChanged(selectedColor);
              setState(() {
                initialColor = selectedColor;
              });
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: initialColor,
            foregroundColor:
                ThemeData.estimateBrightnessForColor(initialColor) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            side: BorderSide(
              color: ThemeData.estimateBrightnessForColor(initialColor) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black, // You can customize the border color
              width: 2, // You can customize the border width
            ),
          ),
          child: Text('Choose a ${widget.instructionText.toLowerCase()} color'),
        ),
      ],
    );
  }
}
