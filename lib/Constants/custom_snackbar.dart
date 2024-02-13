
import 'package:flutter/material.dart';

class CustomSnackBar {
  static late BuildContext context;

  static errorSnackBar(String message,BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

  static successSnackBar(String message,BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.lightGreen,
        ),
      );
}
