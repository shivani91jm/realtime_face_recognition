import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
class FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green // Color of the rectangle
      ..strokeWidth = 2 // Border width
      ..style = PaintingStyle.stroke; // Fill style - stroke to draw outline

    final rect = Rect.fromLTWH(40,200,320,400);
      //  size.width! /2 , size.height / 4, size.width / 2, size.height / 2);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}