import 'package:flutter/material.dart';

class AppFontFamilyClass{
  static const String   fontfamily= "Lexend";
  static const TextStyle regular = TextStyle(
    fontFamily: fontfamily,
    fontWeight: FontWeight.normal,
    fontSize: 30.0,
    color: Colors.black87
    // Add other properties as needed
  );

  static const TextStyle bold = TextStyle(
    fontFamily: fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: 17.0,
      color: Colors.white
    // Add other properties as needed
  );
  static const TextStyle bluebold = TextStyle(
    fontFamily: fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: 25.0,
      color: Colors.blue
    // Add other properties as needed
  );



}