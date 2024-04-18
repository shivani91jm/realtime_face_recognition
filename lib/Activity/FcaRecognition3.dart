import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:realtime_face_recognition/Activity/SettingPage.dart';
import 'package:realtime_face_recognition/Activity/StaffRegistrationPage.dart';
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognition2.dart';
import 'package:http/http.dart' as http;
import 'package:realtime_face_recognition/ML/UserData.dart';
class StaffRecognationPage2 extends StatefulWidget  {
  late List<CameraDescription> cameras;
  StaffRecognationPage2({Key? key, required this.cameras}) : super(key: key);
  @override
  _StaffRecognationPage2State createState() => _StaffRecognationPage2State();
}
class _StaffRecognationPage2State extends State<StaffRecognationPage2> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = widget.cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;

  //TODO declare face detector
  late FaceDetector faceDetector;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  var imgage2;
  List<UserData> users = [];
  bool loading = false;
  String _similarity = "nil";
  var image1 =  regula.MatchFacesImage();
  var image2 =  regula.MatchFacesImage();
  bool isMatching = false;
  File? _image;
  var image;
  int trialNumber = 0;
  List<Face> faces = [];
  get _playFailedAudio =>
      _audioPlayer
        ..stop()
        ..setReleaseMode(ReleaseMode.release)
        ..play(AssetSource("failed.mp3"));
  get _playScanningAudio => _audioPlayer
    ..setReleaseMode(ReleaseMode.loop)
    ..play(AssetSource("scan_beep.wav"));

  late Timer _timer;
  late Recognizer222 recognizer222;
  bool _sacn=false;
  @override
  void initState() {
    super.initState();
    recognizer222 = Recognizer222();
    initializeCamera(widget.cameras[1]);
  }
  //TODO code to initialize the camera feed
  initializeCamera(CameraDescription cameraDescription) async {
    try {
      controller = CameraController(cameraDescription, ResolutionPreset.high,imageFormatGroup: ImageFormatGroup.yuv420);
      try {
        await controller.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          controller.startImageStream((img) async {
            if (!isBusy) {
              isBusy = true;
              doFaceDetection(img,description);
            }
          });
        });
      } on CameraException catch (e) {
        debugPrint("camera error $e");
      }
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  //TODO close all resources
  @override
  void dispose() {
    // controller?.dispose();
    //_faceDetector.close();
    super.dispose();
  }
  doFaceDetection(CameraImage frame, CameraDescription description) async {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }
    InputImage? inputImage = recognizer222.getInputImage(frame, description);
    //TODO pass InputImage to face detection model and detect faces
    final faces = await _faceDetector.processImage(inputImage!);

    if (faces.length > 0) {

      final XFile? photo = await controller?.takePicture();
      _image = File(photo!.path);
      final inputImage = InputImage.fromFile(_image!);
      print('Face detected' + photo!.path.toString() + "inpit" +
          inputImage.filePath.toString());

      List faces = await _faceDetector.processImage(inputImage);
      img.Image faceImg2;
      if (faces.length > 0) {
        image = await _image?.readAsBytes();
        image = await decodeImageFromList(image);
        for (Face face in faces) {
          Rect faceRect = face.boundingBox;
          num left = faceRect.left<0?0:faceRect.left;
          num top = faceRect.top<0?0:faceRect.top;
          num right = faceRect.right>image.width?image.width-1:faceRect.right;
          num bottom = faceRect.bottom>image.height?image.height-1:faceRect.bottom;
          num width = right - left;
          num height = bottom - top;

          //TODO crop face
          final bytes = _image!.readAsBytesSync();

          img.Image? faceImg = img.decodeImage(bytes!);
          faceImg2 = img.copyCrop(faceImg!,x:left.toInt(),y:top.toInt(),width:width.toInt(),height:height.toInt());
          //  _faceFeatures = await extractFaceFeatures(inputImage, _faceDetector);
          var bytesggg= Uint8List.fromList(img.encodePng(faceImg2));
          image2.bitmap = base64Encode(bytesggg);
          image2.imageType = regula.ImageType.PRINTED;


        }
        _fetchUsersAndMatchFace();
      }

    }
    else
    {

      setState(() {
        isBusy=false;
      });
    }
  }

  _fetchUsersAndMatchFace() {
    FirebaseFirestore.instance.collection("users").get().catchError((e) {
      log("Getting User Error: $e");
      setState(() => isMatching = false);
      _playFailedAudio;
      CustomSnackBar.errorSnackBar("Something went wrong. Please try again.",context);
    }).then((snap) {
      if (snap.docs.isNotEmpty) {
        users.clear();
        log(snap.docs.length.toString(), name: "Total Registered Users");
        for (var doc in snap.docs) {
          UserData user = UserData.fromJson(doc.data());
         users.add(user);
        }
        if(mounted)
        {
          setState(() {
            _sacn = true;
          });
        }
        matchFaces(users);
      }
      else {
        _showFailureDialog(
          title: "No Users Registered",
          description: "Make sure users are registered first before Authenticating.",
        );
      }
    });
  }

  matchFaces( List<UserData> users) async {
    bool faceMatched = false;
    await Future.wait(users.map((user) async {

      print("fd" + user.image.toString());
      image1.bitmap = user.image;
      image1.imageType = regula.ImageType.PRINTED;
      var request = regula.MatchFacesRequest();
      request.images = [image1, image2];
      dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));
      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75);

      var split = regula.MatchFacesSimilarityThresholdSplit.fromJson(
          json.decode(str));
      if (mounted) {
        setState(() {
          _similarity =
          split!.matchedFaces.isNotEmpty ? (split.matchedFaces[0]!.similarity! *
              100).toStringAsFixed(2) : "error";
          log("similarity: $_similarity");

          if (_similarity != "error" && double.parse(_similarity) > 85.00) {
            faceMatched = true;
            _sacn = false;
            print("matched ..........");
          }
          else {
            faceMatched = false;
          }
          if (faceMatched) {
            _audioPlayer
              ..stop()
              ..setReleaseMode(ReleaseMode.release)
              ..play(AssetSource("sucessAttendance.m4r"));

            setState(() {
              trialNumber = 1;
              isMatching = false;
            });

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UserDetailsView(user: user!),
                ),
              );

              // isBusy = false;
            }
            return ;
          }
        });
      }
    }));
    if (!faceMatched) {
      if (trialNumber == 4) {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          title: "Redeem Failed",
          description: "Face doesn't match. Please try again.",
        );
      }
      else if (trialNumber == 3) {
        _audioPlayer.stop();
        if(mounted){
          setState(() {
            isMatching = false;
            trialNumber++;
            _sacn=false;
          });
        }

      }
      else {

        if(mounted)
        {
          setState(() {

            trialNumber++;
            _sacn=false;
          });
          _showFailureDialog(
            title: "Redeem Failed",
            description: "Face doesn't match. Please try again.",
          );
        }
      }
    }

  }

  Future<File> urlToFile(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final imageName = 'my_image.png'; // Set a desired file name
    final appDir = await getApplicationDocumentsDirectory();
    final localPath = '${appDir.path}/$imageName';
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return imageFile;
  }

  void _toggleCameraDirection() async {
    var camera=  await availableCameras();
    initializeCamera(camera[1]);
    isBusy=false;
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
                setState(() {
                  isBusy=false;
                });
              },
              child: const Text(
                "Try Again",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context!, MaterialPageRoute(builder: (context) => SettingPage()),);
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {

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
            (controller == null || !controller!.value.isInitialized) ? Center(child: CircularProgressIndicator()): CameraPreview(controller),
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: FacePainter(), // Assuming you have a FacePainter class
            ),
            // if (_sacn)
            //   Align(
            //     alignment: Alignment.center,
            //     child: Padding(
            //       padding: EdgeInsets.only(top: 30),
            //       child: const AnimatedView(),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }






}





