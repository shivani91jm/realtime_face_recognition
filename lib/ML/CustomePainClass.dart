import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// class FacePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.green // Color of the rectangle
//       ..strokeWidth = 2 // Border width
//       ..style = PaintingStyle.stroke; // Fill style - stroke to draw outline
//
//     final rect = Rect.fromLTWH(40,200,320,400);
//       //  size.width! /2 , size.height / 4, size.width / 2, size.height / 2);
//     canvas.drawRect(rect, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.faces, this.absoluteImageSize);

  final Size absoluteImageSize;
  final List<Face> faces;


  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;


    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (var face in faces) {
      final Rect rect = Rect.fromPoints(
        Offset(face.boundingBox.left, face.boundingBox.top),
        Offset(face.boundingBox.right, face.boundingBox.bottom),
      );
      canvas.drawRect(rect, paint);
    }

  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}