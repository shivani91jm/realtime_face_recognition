import 'package:flutter/material.dart';
import 'package:realtime_face_recognition/Utils/Appcolors.dart';

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
      color: Colors.white,
    fontStyle: FontStyle.normal,
    // Add other properties as needed
  );
  static const TextStyle bluebold = TextStyle(
    fontFamily: fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: 25.0,
      color: Colors.blue,
    fontStyle: FontStyle.normal,
    // Add other properties as needed
  );
  static const TextStyle blackebold = TextStyle(
    fontFamily: fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
    color: AppColors.textColorsBlack,

     fontStyle: FontStyle.normal,
    // Add other properties as needed
  );
  static const TextStyle lightbold = TextStyle(
    fontFamily: fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
    color: Colors.blue,

     fontStyle: FontStyle.normal,
    // Add other properties as needed
  );
  static const TextStyle redtbold = TextStyle(
    fontFamily: fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
    color: AppColors.red,

     fontStyle: FontStyle.normal,
    // Add other properties as needed
  );





}