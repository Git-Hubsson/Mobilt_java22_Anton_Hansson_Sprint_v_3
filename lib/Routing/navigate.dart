import 'package:flutter/material.dart';

class Navigate {
  static void navigateTo(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}