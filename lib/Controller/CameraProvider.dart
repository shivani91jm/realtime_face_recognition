import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraProvider with ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  List<Face> _faces = [];
  CameraProvider() {
    _initializeFaceDetector();
    _initializeCamera();

  }
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[1], ResolutionPreset.medium);
    await _controller!.initialize();
    _controller!.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _detectFaces(image);
      }
    });
    notifyListeners();
  }
  Future<void> _initializeFaceDetector() async {
    var options = FaceDetectorOptions();
    _faceDetector = FaceDetector(options: options);
  }
  CameraController? get cameraController => _controller;

  List<Face> get detectedFaces => _faces;

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }
  Future<void> _detectFaces(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image!.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final Size imageSize = Size(image!.width.toDouble(), image!.height.toDouble());
      final camera = cameras[1];
      final imageRotation =
      InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      // if (imageRotation == null) return;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image!.format.raw);
      // if (inputImageFormat == null) return null;

      final planeData = image!.planes.map(
            (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation!,
        inputImageFormat: inputImageFormat!,
        planeData: planeData,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
      final List<Face> faces = await _faceDetector!.processImage(inputImage);
      _faces = faces;
      _isDetecting = false;
      notifyListeners();
    } catch (e) {
      print('Error detecting faces: $e');
    }
  }

}