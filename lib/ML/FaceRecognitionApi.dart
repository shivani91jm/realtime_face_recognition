import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Controller/AttendanceController.dart';
import 'package:realtime_face_recognition/Controller/RecognitionController.dart';
import 'package:realtime_face_recognition/DB/DatabaseHelper.dart';
import 'package:realtime_face_recognition/ML/CustomePainClass.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognition2.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/ML/UserData.dart';
import 'package:http/http.dart' as http;


class StaffRecognationPage2 extends StatefulWidget  {
  late List<CameraDescription> cameras;
  StaffRecognationPage2({Key? key, required this.cameras}) : super(key: key);
  @override
  _StaffRecognationPage2State createState() => _StaffRecognationPage2State();
}
class _StaffRecognationPage2State extends State<StaffRecognationPage2> {
  RecognitionController recognitionController = Get.put(RecognitionController());
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = widget.cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;
  late List<Recognition> recognitions = [];
  //TODO declare face detector
  late FaceDetector faceDetector;
  //TODO declare face recognizer
  final Recognizer222 recognizer=Recognizer222();
  final AudioPlayer _audioPlayer = AudioPlayer();
  static String flag = "1";
  AttendanceController aatedancecontroller=Get.put(AttendanceController());

  var imgage2;
  final dbHelper = DatabaseHelper();

  bool loading = false;
  String _similarity = "nil";
  String _liveness = "nil";
  var image1 = new MatchFacesImage();
  var image2 = new MatchFacesImage();
  bool isMatching = false;
  File? _image;
  var image;
  int trialNumber = 0;
  get _playFailedAudio => _audioPlayer
    ..stop()
    ..setReleaseMode(ReleaseMode.release)
    ..play(AssetSource("failed.mp3"));
  late Timer _timer;
  List<MatchFacesRequest> requests = [];
  @override
  void initState() {
    initPlatformState();
    super.initState();
    var options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    //TODO initialize face recognizer

    //TODO initialize camera footage
    initializeCamera();

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


  //TODO code to initialize the camera feed
  initializeCamera() async {
    await dbHelper.init();


    try {
      controller = CameraController(widget.cameras[1], ResolutionPreset.high);
      try {
        await controller.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _startAutoCapture();

        });

      } on CameraException catch (e) {
        debugPrint("camera error $e");
      }
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }
  void _startAutoCapture() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if(!isBusy)
        {
          isBusy=true;
          takePicture();
        }
    });
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

  Future takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    // if (controller.value.isTakingPicture) {
    //   return null;
    // }
    if(!controller.value.isTakingPicture)
      {
        try {
          await controller.setFlashMode(FlashMode.off);

          XFile picture = await controller.takePicture();
          final inputImage = InputImage.fromFilePath(picture.path);
          final faces = await faceDetector.processImage(inputImage);
          if (faces.isNotEmpty) {
            // Face detected, save the image or perform other actions
            print('Face detected! Capturing photo...');
            setImage(
                true,
                File(picture!.path).readAsBytesSync(),
                ImageType.PRINTED);



           // initDB();

          } else {
            // No face detected, do not capture photo
            print('No face detected, skipping photo capture.');
            _startAutoCapture();
          }





        } on CameraException catch (e) {
          debugPrint('Error occured while taking picture: $e');
          return null;
        }
      }
  }
  List<Face> faces = [];
  @override
  void dispose() {
    controller?.dispose();
    faceDetector.close();
    super.dispose();
  }
  setImage(bool first, Uint8List imageFile, int type,) {
    if (first) {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
      matchFaces();
    }

  }
  doFaceDetection(CameraImage frame,CameraDescription description) async {

    if (controller == null || !controller!.value.isInitialized) {
      // Controller is not initialized, do nothing
      return;
    }
    Timer.periodic(Duration(seconds: 2), (Timer t) async {
      if (isBusy) {
        // A picture is currently being processed, do nothing
        return;
      }
      isBusy = true;
    InputImage? inputImage = recognizer.getInputImage(frame, description);
    //TODO pass InputImage to face detection model and detect faces
    final faces = await faceDetector.processImage(inputImage!);
    if (faces.length > 0) {
      Timer.periodic(Duration(seconds: 2), (Timer t) async {
        final XFile? photo = await controller?.takePicture();

        // Crop image to face
        final bytes = await File(photo!.path).readAsBytes();
        setImage(
            true,
            File(photo!.path).readAsBytesSync(),
            ImageType.PRINTED);
      });
      isBusy=false;
    }
    });
  }
  matchFaces() async{
    print("dhfhjdhfd"+recognizer.users.length.toString());
    bool faceMatched=false;

    recognizer.users.sort((a, b) => double.tryParse(a.id)!.compareTo(double.tryParse(b.id)!));
//     for (UserData user in recognizer.users) {
//       image2.bitmap = user.targetimage;
//       image2.imageType = ImageType.PRINTED;
//       var request = new MatchFacesRequest();
//       request.images = [image1, image2];
//       requests.add(request);
//
//       FaceSDK.matchFaces(jsonEncode(requests)).then((value) {
//         var response = MatchFacesResponse.fromJson(json.decode(value));
//         FaceSDK.matchFacesSimilarityThresholdSplit(
//             jsonEncode(response!.results), 0.75)
//             .then((str) {
//           var split = MatchFacesSimilarityThresholdSplit.fromJson(
//               json.decode(str));
//
//           setState(() {
//             _similarity = split!.matchedFaces.isNotEmpty
//                 ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
//                 : "error";
//             log("similarity: $_similarity");
//
//             if (_similarity != "error" && double.parse(_similarity) > 90.00) {
//               //print("hghg" + user.name);
//               faceMatched = true;
//               setState(() {
//                 trialNumber = 1;
//                 //isMatching = false;
//               });
//
//               _audioPlayer
//                 ..stop()
//                 ..setReleaseMode(ReleaseMode.release)
//                 ..play(AssetSource("sucessAttendance.m4r"));
//               // UserData data = UserData(
//               //     user.name, image1.bitmap!, user.id, image2.bitmap!);
//               //
//               // Navigator.push(context, MaterialPageRoute(builder: (context) =>  UserDetailsView(user: data,)),);
//
//             } else {
//               faceMatched = false;
//               print("no image found");
//             }
//           });
//         });
//       });
//
// // Example: Using async/await to parallelize API calls
//
//
//       // if (!faceMatched) {
//       //   if (trialNumber == 4) {
//       //     setState(() => trialNumber = 1);
//       //     // _showFailureDialog(
//       //     //   title: "Redeem Failed",
//       //     //   description: "Face doesn't match. Please try again.",
//       //     // );
//       //   }
//       //   else if (trialNumber == 3) {
//       //     //After 2 trials if the face doesn't match automatically, the registered name prompt
//       //     //will be shown. After entering the name the face registered with the entered name will
//       //     //be fetched and will try to match it with the to be authenticated face.
//       //     //If the faces match, Viola!. Else it means the user is not registered yet.
//       //     _audioPlayer.stop();
//       //     setState(() {
//       //       isMatching = false;
//       //       trialNumber++;
//       //     });
//       //     // showDialog(
//       //     //     context: context,
//       //     //     builder: (context) {
//       //     //       return AlertDialog(
//       //     //         title: const Text("Enter Name"),
//       //     //         content: TextFormField(
//       //     //           controller: _nameController,
//       //     //           cursorColor: accentColor,
//       //     //           decoration: InputDecoration(
//       //     //             enabledBorder: OutlineInputBorder(
//       //     //               borderSide: const BorderSide(
//       //     //                 width: 2,
//       //     //                 color: accentColor,
//       //     //               ),
//       //     //               borderRadius: BorderRadius.circular(4),
//       //     //             ),
//       //     //             focusedBorder: OutlineInputBorder(
//       //     //               borderSide: const BorderSide(
//       //     //                 width: 2,
//       //     //                 color: accentColor,
//       //     //               ),
//       //     //               borderRadius: BorderRadius.circular(4),
//       //     //             ),
//       //     //           ),
//       //     //         ),
//       //     //         actions: [
//       //     //           TextButton(
//       //     //             onPressed: () {
//       //     //               if (_nameController.text.trim().isEmpty) {
//       //     //                 CustomSnackBar.errorSnackBar("Enter a name to proceed");
//       //     //               } else {
//       //     //                 Navigator.of(context).pop();
//       //     //                 setState(() => isMatching = true);
//       //     //                 _playScanningAudio;
//       //     //                 _fetchUserByName(_nameController.text.trim());
//       //     //               }
//       //     //             },
//       //     //             child: const Text(
//       //     //               "Done",
//       //     //               style: TextStyle(
//       //     //                 color: accentColor,
//       //     //               ),
//       //     //             ),
//       //     //           )
//       //     //         ],
//       //     //       );
//       //     //     });
//       //   }
//       //   else {
//       //     setState(() => trialNumber++);
//       //     _showFailureDialog(
//       //       title: "Redeem Failed",
//       //       description: "Face doesn't match. Please try again.",
//       //     );
//       //   }
//       // }
//     }
    await Future.wait(recognizer.users.map((user) async {
      image1.bitmap = user.targetimage;
      image1.imageType = ImageType.PRINTED;
      var request = new MatchFacesRequest();
      request.images = [image1, image2];
      FaceSDK.matchFaces(jsonEncode(request)).then((value) {
        var response = MatchFacesResponse.fromJson(json.decode(value));
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
              faceMatched = true;
              setState(() {
                trialNumber = 1;
                //isMatching = false;
              });

              _audioPlayer
                ..stop()
                ..setReleaseMode(ReleaseMode.release)
                ..play(AssetSource("sucessAttendance.m4r"));
              UserData data = UserData(
                  user.name, image1.bitmap!, user.id, image2.bitmap!);

             // Navigator.push(context, MaterialPageRoute(builder: (context) =>  UserDetailsView(user: data,)),);

            } else {
              faceMatched = false;
              print("no image found");
            }
          });
        });
      });
    }));
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

    initializeCamera();
    setState(() {
      // controller;
      isBusy = false;
    });
  }

  _showFailureDialog({
    required String title,
    required String description,
  }) {
    _playFailedAudio;
    setState(() => isMatching = false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            )
          ],
        );
      },
    );

  }




  @override
  Widget build(BuildContext context) {
    if(controller==null) {
      return Center(child: CircularProgressIndicator(color: Colors.blue,),);

    }

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
          margin: const EdgeInsets.only(top: 0),
          color: Colors.black,
          child:Stack(
            children: <Widget>[
              CameraPreview(controller),
              // CustomPaint(
              //   size: MediaQuery.of(context).size,
              //   painter: FacePainter(), // Assuming you have a FacePainter class
              // ),
            ],
          ),
      ),
    );
  }


  removeRotation(File inputImage) async {
    final img.Image? capturedImage = img.decodeImage(await File(inputImage!.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }
}





