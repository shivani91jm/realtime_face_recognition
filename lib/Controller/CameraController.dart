import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CameraControllers extends GetxController {
  late CameraController controller;
//  RxBool isBusy = false.obs;
//  late CameraImage? frame;
  late FaceDetector faceDetector;
  RxList<Face> scanResults = <Face>[].obs;
  late List<Recognition> recognitions = [];
  img.Image? image;
  final AudioPlayer _audioPlayer = AudioPlayer();
  BuildContext? context=Get.context;
  late Recognizer recognizer;
  CameraLensDirection camDirec = CameraLensDirection.front;

  final RxBool isBusy = false .obs ;
  //final Rx<CameraImage> frame = Rx<CameraImage>(Uint8List(0), 0, 0, 0, ImageFormat.group);
  CameraImage? frame;
  late CameraController cameraController;
  late List<CameraDescription> _cameras;
  RxBool isCapturing = false.obs;
  // CameraControllers(CameraDescription cameraDescription) {
  //   controller = CameraController(cameraDescription, ResolutionPreset.high);
  // }
  @override
  void onInit() {
    super.onInit();
   // initializeCamera();
    var options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    //TODO initialize face recognizer
  //  recognizer = Recognizer();
  }
  Future<void> initializeCamera(List<CameraDescription> cameraDescription) async {
    try {

      _cameras=cameraDescription;
      _cameras=cameraDescription;
      cameraController = CameraController(cameraDescription[1], ResolutionPreset.medium);
      await cameraController.initialize();
      cameraController.startImageStream((CameraImage image) {
        frame = image;

        if (!isBusy.value) {
          isBusy.value = true;
          doFaceDetectionOnFrame();
        }
      });
    } on CameraException catch (e) {
      Get.snackbar("Camera Error", "Failed to initialize camera: $e");
    }
  }
  doFaceDetectionOnFrame() async {
    //TODO convert frame into InputImage format
    // Convert CameraImage to InputImage
    InputImage inputImage = getInputImage();

    // Pass InputImage to face detection model and detect faces
    List<Face> faces = await faceDetector.processImage(inputImage);

    // Update the state with detected faces
    scanResults.assignAll(faces);

    // Reset the busy flag
    isBusy.value = false;

    /// Perform face recognition on detected faces if needed
    // performFaceRecognition(faces);


  }
  //TODO convert CameraImage to InputImage
  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(frame!.width.toDouble(), frame!.height.toDouble());
    final camera = _cameras[1];
    final imageRotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat = InputImageFormatValue.fromRawValue(frame!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = frame!.planes.map(
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

    return inputImage;
  }
}