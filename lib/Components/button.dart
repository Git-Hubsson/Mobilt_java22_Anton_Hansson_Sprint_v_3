import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MyButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(19, 30, 29, 1.0),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromRGBO(159, 210, 205, 1.0),
        ),
      ),
    );
  }
}
