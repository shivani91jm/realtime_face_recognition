import 'dart:developer';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognizer.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/Model/Userattendancemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StaffRecognationPage extends StatefulWidget {
  late List<CameraDescription> cameras;
  StaffRecognationPage({Key? key, required this.cameras}) : super(key: key);
  @override
  _StaffRecognationPageState createState() => _StaffRecognationPageState();
}

class _StaffRecognationPageState extends State<StaffRecognationPage> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = widget.cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;
  late List<Recognition> recognitions = [];

  //TODO declare face detector
  late FaceDetector faceDetector;

  //TODO declare face recognizer
  late Recognizer recognizer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    var options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    //TODO initialize face recognizer
    recognizer = Recognizer();
    //TODO initialize camera footage
    initializeCamera(widget.cameras[1]);
    // initCamera(widget.cameras![1]);
  }

  //TODO code to initialize the camera feed
  initializeCamera(CameraDescription cameraDescription) async {
    controller = CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await controller.initialize().then((_) {
        if (!mounted) return;
        controller.startImageStream((image) async {
          if(!isBusy)
          {
            isBusy=true;
            frame = image;
            doFaceDetectionOnFrame();

          }
        });
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  //TODO close all resources
  @override
  void dispose() {
    controller?.dispose();
    recognitions.clear();
    faceDetector.close();
   // _audioPlayer.dispose();
    super.dispose();
  }

  //TODO face detection on a frame
  dynamic _scanResults;
  CameraImage? frame;
  doFaceDetectionOnFrame() async {
    //TODO convert frame into InputImage format
    InputImage inputImage = getInputImage();
    //TODO pass InputImage to face detection model and detect faces
    List<Face> faces = await faceDetector.processImage(inputImage);
     setState(() {

        _scanResults = faces;
       // isBusy = false;

    });
    //TODO perform face recognition on detected faces
    performFaceRecognition(faces);

  }

  img.Image? image;
  bool register = false;
  // TODO perform Face Recognition
  performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    //TODO convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(frame!);
    image =img.copyRotate(image!, angle: camDirec == CameraLensDirection.front?270:90);

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      //TODO crop face
      img.Image croppedFace = img.copyCrop(image!, x:faceRect.left.toInt(),y:faceRect.top.toInt(),width:faceRect.width.toInt(),height:faceRect.height.toInt());

      //TODO pass cropped face to face recognition model
      Recognition recognition = recognizer.recognize(croppedFace!, faceRect);
      if(recognition.distance>0.9){
        recognition.name = "Unknown";
      }

      recognitions.add(recognition);
      if(recognition.name!="Unknown")
        {

          if (mounted) {
            _audioPlayer
              ..stop()
              ..setReleaseMode(ReleaseMode.release)
              ..play(AssetSource("sucessAttendance.m4r"));
               Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) =>
                    UserDetailsView(user: recognition,)),
               );
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('page', '1');
          }

        }
      else
        {
          if(mounted)
            {
              CustomSnackBar.errorSnackBar("Unknown User",context);

            }
        }



    }

    // setState(() {
    // //   isBusy  = false;
    //    _scanResults = recognitions;
    //  });

  }
  // TODO method to convert CameraImage to Image
  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
    final image = img.Image(width:width, height:height);
    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data!.setPixelR(w, h, yuv2rgb(y, u, v));//= yuv2rgb(y, u, v);
      }
    }
    return image;
  }
  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 | ((b << 16) & 0xff0000) | ((g << 8) & 0xff00) | (r & 0xff);
  }

  //TODO convert CameraImage to InputImage
  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(frame!.width.toDouble(), frame!.height.toDouble());
    final camera = description;
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

  // TODO Show rectangles around detected faces
  Widget buildResult() {
    if (controller == null ||
        !controller.value.isInitialized) {
      return const  Center(child: CircularProgressIndicator());
    }
    if(_scanResults==null)
      {
        return const Center(child: Text(""));
      }
    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter = FaceDetectorPainter(imageSize, _scanResults, camDirec);
    return CustomPaint(
      painter: painter,
    );
  }

  //TODO toggle camera direction
  void _toggleCameraDirection() async {
    // if (camDirec == CameraLensDirection.back) {
    //   camDirec = CameraLensDirection.front;
    //   description = widget.cameras[1];
    // } else {
    //   camDirec = CameraLensDirection.back;
    //   description = widget.cameras[0];
    // }
    // await controller.stopImageStream();

    initializeCamera(widget.cameras[1]);
    setState(() {
     // controller;
      isBusy  = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {

      //TODO View for displaying the live camera footage
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            )
                : Container(),
          ),
        ),
      );

      //TODO View for displaying rectangles around detected aces
      stackChildren.add(
        Positioned(
            top: 0.0,
            left: 0.0,
            width: size.width,
            height: size.height,
            child: buildResult()),
      );
    }

    //TODO View for displaying the bar to switch camera direction or for registering faces
    // stackChildren.add(Positioned(
    //   top: size.height - 140,
    //   left: 0,
    //   width: size.width,
    //   height: 80,
    //   child: Card(
    //     margin: const EdgeInsets.only(left: 20, right: 20),
    //     color: Colors.blue,
    //     child: Center(
    //       child: Container(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               children: [
    //                 IconButton(
    //                   icon: const Icon(
    //                     Icons.cached,
    //                     color: Colors.white,
    //                   ),
    //                   iconSize: 40,
    //                   color: Colors.black,
    //                   onPressed: () {
    //                     _toggleCameraDirection();
    //                   },
    //                 ),
    //                 Container(
    //                   width: 30,
    //                 ),
    //                 IconButton(
    //                   icon: const Icon(
    //                     Icons.face_retouching_natural,
    //                     color: Colors.white,
    //                   ),
    //                   iconSize: 40,
    //                   color: Colors.black,
    //                   onPressed: () {
    //                     setState(() {
    //                       register = true;
    //                     });
    //                   },
    //                 )
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // ));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          actions: [
                           IconButton(
                            icon: const Icon(
                              Icons.cached,
                              color: Colors.white,
                            ),
                            iconSize: 40,
                            color: Colors.black,
                            onPressed: () {
                              _toggleCameraDirection();
                            },
                          ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Container(
            margin: const EdgeInsets.only(top: 0),
            color: Colors.black,
            child: Stack(
              children: stackChildren,
            )
        ),
      ),
    );
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces, this.camDire2);

  final Size absoluteImageSize;
  final List<Face> faces;
  CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    for (Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.right) * scaleX
              : face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          camDire2 == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.left) * scaleX
              : face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY,
        ),
        paint,
      );

      // TextSpan span = TextSpan(
      //     style: const TextStyle(color: Colors.white, fontSize: 20),
      //     text: "${face.name}  ${face.distance.toStringAsFixed(2)}");
      // TextPainter tp = TextPainter(
      //     text: span,
      //     textAlign: TextAlign.left,
      //     textDirection: TextDirection.ltr);
      // tp.layout();
      // tp.paint(canvas, Offset(face.location.left*scaleX, face.location.top*scaleY));
    }

  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
