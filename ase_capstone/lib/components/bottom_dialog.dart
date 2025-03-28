import 'package:flutter/material.dart';
import 'dart:async';

class BottomDialog extends StatefulWidget {
  final String message;
  final Function(bool) onResponse;
  const BottomDialog({
    super.key,
    required this.message,
    required this.onResponse,
  });

  @override
  State<BottomDialog> createState() => _BottomDialogState();
}

class _BottomDialogState extends State<BottomDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      // close the widget if it is still on the screen and the user hasnt given input for 5 seconds
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.message,
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    widget.onResponse(true);
                    Navigator.of(context).pop();
                    _timer?.cancel();
                  },
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onResponse(false);
                    Navigator.of(context).pop();
                    _timer?.cancel();
                  },
                  child: Text('No'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
