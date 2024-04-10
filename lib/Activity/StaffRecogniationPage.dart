import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Controller/CameraProvider.dart';
import 'package:realtime_face_recognition/Controller/FaceDetectorWidget.dart';
import 'package:realtime_face_recognition/ML/CustomePainClass.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognition2.dart';
import 'package:realtime_face_recognition/ML/Recognizer.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/ML/UserData.dart';
import 'package:realtime_face_recognition/Model/Userattendancemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StaffRecognationPage extends StatefulWidget  {
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
  final _convertNativeImgStreamPlugin = ConvertNativeImgStream();
  //TODO declare face detector
  late FaceDetector faceDetector;

  //TODO declare face recognizer
  late Recognizer recognizer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  static  String flag="1";
  Uint8List? imageBytes;
  File? imageFile;
  late Recognizer222 recognizer222;
  String _similarity = "nil";
  String _liveness = "nil";
  var image1 = new MatchFacesImage();
  var image2 = new MatchFacesImage();
  BuildContext? contextss= Get.context;
  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    var options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    //TODO initialize face recognizer
    recognizer = Recognizer();
    recognizer222 = Recognizer222();
    //TODO initialize camera footage
   initializeCamera(widget.cameras[1]);
    const EventChannel('flutter_face_api/event/video_encoder_completion')
        .receiveBroadcastStream()
        .listen((event) {
      var completion = VideoEncoderCompletion.fromJson(json.decode(event))!;
      print("VideoEncoderCompletion:");
      print("    success:  ${completion.success}");
      print("    transactionId:  ${completion.transactionId}");
    });
    const EventChannel('flutter_face_api/event/onCustomButtonTappedEvent')
        .receiveBroadcastStream()
        .listen((event) {
      print("Pressed button with id: $event");
    });
    const EventChannel('flutter_face_api/event/livenessNotification')
        .receiveBroadcastStream()
        .listen((event) {
      var notification = LivenessNotification.fromJson(json.decode(event));
      print("LivenessProcessStatus: ${notification!.status}");
    });
  }

  //TODO code to initialize the camera feed
  initializeCamera(CameraDescription cameraDescription) async {
    controller = CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        controller.startImageStream((image) async {
          if(!isBusy)
          {
            isBusy=true;
            frame = image;
            doFaceDetectionOnFrame(contextss!);

          }});
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
     _audioPlayer.dispose();
    super.dispose();
  }

  //TODO face detection on a frame
  dynamic _scanResults;
  CameraImage? frame;
  doFaceDetectionOnFrame(BuildContext context) async {
    try{
      recognitions.clear();

      //TODO convert frame into InputImage format
      InputImage? inputImage = recognizer222.getInputImage(frame!,description);
      Uint8List? imageBytes = await inputImage!.bytes;
      File imageFile = await createTemporaryFile();
      var bbb= await imageFile.writeAsBytes(imageBytes!);
      image2.bitmap=base64Encode(bbb.readAsBytesSync());
      image2.imageType=ImageType.PRINTED;
      //TODO pass InputImage to face detection model and detect faces
      List<Face> faces = await faceDetector.processImage(inputImage!);
      //TODO perform face recognition on detected faces
      // setState(() {
            _scanResults = faces;
         //   isBusy = false;
         // });
          performFaceRecognition(faces,context);
    } catch(e){
      CustomSnackBar.errorSnackBar("Face Detcion Problem Please Refresh",context);
    }
    finally{
     // setState(() => isBusy = false);
    }


  }
  Future<File> createTemporaryFile() async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/my_image.png');
    return tempFile;
  }
  double calculateBrightness(CameraImage image) {
    double sum = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        sum += image.planes[0].bytes[y * image.width + x] & 0xFF;
      }
    }
    double brightness = sum / (image.width * image.height);
    return brightness;
  }


  img.Image? image;
  bool register = false;
  // TODO perform Face Recognition
  performFaceRecognition(List<Face> faces,BuildContext context) async {

    //TODO convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(frame!);
    image =img.copyRotate(image!, angle: camDirec == CameraLensDirection.front?270:90);

    for (Face face in faces) {
      // var faceRect = face!.boundingBox;
      //
      // // Calculate the width and height of the bounding box
      // int? width = (faceRect.right! - faceRect.left!).toInt();
      // int height = (faceRect.bottom! - faceRect.top!).toInt();
      //
      // // Get the left and top coordinates of the bounding box
      // int left = faceRect.left!.toInt();
      // int top = faceRect.top!.toInt();
      //
      // // Crop the face directly from the image
      // img.Image croppedFace = img.copyCrop(image!, x: left, y: top, width: width, height: height);
      //


      //TODO pass cropped face to face recognition model
      Recognition recognition = recognizer.recognize(image!,  face.boundingBox);
      if(recognition.distance>1.2){
        recognition.name = "Unknown";
      }

      recognitions.add(recognition);

      if(recognition.name!="Unknown")
      {
        var ur="https://"+recognition.imageUrl;
        File userss=await recognizer.urlToFile(ur);
        image1.bitmap = base64Encode(File(userss!.path).readAsBytesSync() );
        image1.imageType =  ImageType.PRINTED;
        var request = new MatchFacesRequest();
        request.images = [image1, image2];
        print("hjdsfjk"+request.images.toString());
        FaceSDK.matchFaces(jsonEncode(request)).then((value) {
          var response = MatchFacesResponse.fromJson(json.decode(value));
          print("object+"+response.toString());
          FaceSDK.matchFacesSimilarityThresholdSplit(
              jsonEncode(response!.results), 0.75)
              .then((str) {
            var split = MatchFacesSimilarityThresholdSplit.fromJson(
                json.decode(str));

            setState(() {
              _similarity = split!.matchedFaces.isNotEmpty
                  ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
                  : "error";
              log("similarity: $_similarity");

              if (_similarity != "error" && double.parse(_similarity) > 90.00) {
                //print("hghg" + user.name);
                // faceMatched = true;
                //  setState(() {
                //    trialNumber = 1;
                //    //isMatching = false;
                //  });

                _audioPlayer
                  ..stop()
                  ..setReleaseMode(ReleaseMode.release)
                  ..play(AssetSource("sucessAttendance.m4r"));
                // UserData data = UserData(
                //     user.name, image1.bitmap!, user.id, image2.bitmap!);

                Navigator.pushReplacement(context!, MaterialPageRoute(builder: (context) =>  UserDetailsView(user: recognition,)),);

              } else {
                //  faceMatched = false;
                print("no image found");
              }
            });
          });
        });



        // await Future.wait(recognitions!.map((user) async {
        //         File userss=await recognizer.urlToFile(user.imageUrl);
        //   image1.bitmap = base64Encode(File(userss!.path).readAsBytesSync() );
        //   image1.imageType =  ImageType.PRINTED;
        //
        //   var request = new MatchFacesRequest();
        //   request.images = [image1, image2];
        //   FaceSDK.matchFaces(jsonEncode(request)).then((value) {
        //     var response = MatchFacesResponse.fromJson(json.decode(value));
        //     FaceSDK.matchFacesSimilarityThresholdSplit(
        //         jsonEncode(response!.results), 0.75)
        //         .then((str) {
        //       var split = MatchFacesSimilarityThresholdSplit.fromJson(
        //           json.decode(str));
        //
        //       setState(() {
        //         _similarity = split!.matchedFaces.isNotEmpty
        //             ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
        //             : "error";
        //         log("similarity: $_similarity");
        //
        //         if (_similarity != "error" && double.parse(_similarity) > 90.00) {
        //           //print("hghg" + user.name);
        //           // faceMatched = true;
        //           //  setState(() {
        //           //    trialNumber = 1;
        //           //    //isMatching = false;
        //           //  });
        //
        //           _audioPlayer
        //             ..stop()
        //             ..setReleaseMode(ReleaseMode.release)
        //             ..play(AssetSource("sucessAttendance.m4r"));
        //           UserData data = UserData(
        //               user.name, image1.bitmap!, user.id, image2.bitmap!);
        //
        //           Navigator.pushReplacement(context!, MaterialPageRoute(builder: (context) =>  UserDetailsView(user: recognition,)),);
        //
        //         } else {
        //           //  faceMatched = false;
        //           print("no image found");
        //         }
        //       });
        //     });
        //   });
        // }));
      }

      setState(() {
        isBusy=false;
      });
    }

  }
  Future<void> initPlatformState() async {
    var onInitialized = (json) {
      var response = jsonDecode(json);
      if (!response["success"]) {
        print("Init failed: ");
        print(json);
      } else {
        print("Init complete");
      }
    };
    initialize(onInitialized);
  }
  Future<void> initialize(onInit(dynamic response)) async {
    var licenseData = await loadAssetIfExists("assets/regula.license");
    if (licenseData != null) {
      var config = InitializationConfiguration();
      config.license = base64Encode(licenseData.buffer.asUint8List());
      FaceSDK.initializeWithConfig(config.toJson()).then(onInit);
    } else
      FaceSDK.initialize().then(onInit);
  }

  Future<ByteData?> loadAssetIfExists(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
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
        final uvIndex = uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
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
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };



  // TODO Show rectangles around detected faces
  Widget buildResult() {
    if (controller == null) {
      return const  Center(child: CircularProgressIndicator());
    }
    if(_scanResults==null)
    {
      return const Center(child: Text(""));
    }
    // final Size imageSize = Size(
    //   controller.value.previewSize!.height,
    //   controller.value.previewSize!.width,
    // );
    CustomPainter painter = FaceDetectorPainter( _scanResults, MediaQuery.of(contextss!).size);
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
  //   await controller.stopImageStream();

    initializeCamera(widget.cameras[1]);
    setState(() {

      isBusy  = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stackChildren = [];
  //  size = MediaQuery.of(context).size;
    if (controller != null) {

      //TODO View for displaying the live camera footage
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: buildResult()),
      );
    }

    //TODO View for displaying the bar to switch camera direction or for registering faces
    final cameraProvider = Provider.of<CameraProvider>(context);
    final List<Face> faces = cameraProvider.detectedFaces;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}


class FaceDetectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        final detectedFaces = cameraProvider.detectedFaces;
        return Stack(
          children: [
            for (var face in detectedFaces)
              Positioned(
                left: face.boundingBox.left,
                top: face.boundingBox.top,
                width: face.boundingBox.width,
                height: face.boundingBox.height,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2.0),
                  ),
                ),
              ) ,
          ],
        );
      },
    );
  }
}
