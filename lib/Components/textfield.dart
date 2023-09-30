import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: Color.fromRGBO(159, 210, 205, 1.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}