import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Controller/CameraProvider.dart';
import 'package:realtime_face_recognition/Controller/FaceDetectorWidget.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognizer.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/ML/UserData.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Model/Userattendancemodel.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  late List<Recognition> recognitions = [];

  //TODO declare face detector
  late FaceDetector faceDetector;

  //TODO declare face recognizer
  late Recognizer recognizer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  static  String flag="1";
  List<Data>? users;
  var imgage2;
  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    //var options = FaceDetectorOptions();
  //  faceDetector = FaceDetector(options: options);
    //TODO initialize face recognizer
   // recognizer = Recognizer();
    //TODO initialize camera footage
     initializeCamera();
    // initCamera(widget.cameras![1]);
  }

  //TODO code to initialize the camera feed
  initializeCamera() async {
    controller = CameraController(widget.cameras[1], ResolutionPreset.high);
    try {
      // await controller.initialize().then((_) {
      //
      //   // controller.startImageStream((image) async {
      //   //   if(!isBusy)
      //   //   {
      //   //     isBusy=true;
      //   //     frame = image;
      //   //     doFaceDetectionOnFrame();
      //   //
      //   //   }
      //   // });
      //   // setState(() {});
      //   //   controller?.startImageStream(doFaceDetectionOnFrame()).then((value) {
      //   //          isBusy=true;
      //   //           frame = value;
      //   //   });
      //   //   setState(() {});
      // });
      await controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        takePicture();
        setState(() {
          isBusy = true;
        });
      });

    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    if (!controller.value.isInitialized) {return null;}
    if (controller.value.isTakingPicture) {return null;}
    try {
      await controller.setFlashMode(FlashMode.off);
      final XFile? photo = await controller?.takePicture();
      print("fhdhhfhjf"+photo!.path.toString());
      if (photo != null) {
        setState(() {
          imgage2 = _convertImageToBase64(photo.path);
        });
      }
      initDB();


    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  String _convertImageToBase64(String imagePath) {
    final bytes = Uint8List.fromList(File(imagePath).readAsBytesSync());
    final base64String = base64Encode(bytes);
    return base64String;
  }

  //TODO close all resources
  @override
  void dispose() {

    controller?.dispose();
   // recognitions.clear();
    //faceDetector.close();
    // _audioPlayer.dispose();
    super.dispose();
  }

  //TODO face detection on a frame
  dynamic _scanResults;
  CameraImage? frame;
  doFaceDetectionOnFrame() async {
    try{




    } catch(e){
      CustomSnackBar.errorSnackBar("Face Detcion Problem Please Refresh",context);
    }
    finally{
      //setState(() => isBusy = false);
    }


  }
  initDB() async {

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var admin_id = await prefs.getString('admin_id') ?? "";
        var url = Urls.staffListUrl + "admin_id=${admin_id}";
        print("res body" + url.toString());
        final response = await http.get(
          Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},);
        print("response" + response.body.toString());
        if (response.statusCode == 200) {
          StaffListModel res = StaffListModel.fromJson(
              jsonDecode(response.body));
          print("vdbvsbd" + res.toString());
          if (res != null) {
            var info = res.success;

            if (info == true) {
               users  = res.data;

            }
            loadRegisteredFaces();
          }
        }
        else if (response.statusCode == 401) {
          print("data" + response.body.toString());

          // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
        }
        else if (response.statusCode == 500) {
          print("data" + response.body.toString());
        }
        else {
          print("data" + response.body.toString());
        }
      }
    }
    on SocketException catch (_) {

    }
  }

  void loadRegisteredFaces() async {

    for (int i = 0; i < users!.length; i++) {
      String name = users![i].name.toString();
      var id = users![i].id.toString();
      var url = users![i].faceModel;
      String modifiedUrl = url.replaceFirst(
          '\/home\/hqcj8lltjqyi\/public_html\/', '');
      print(modifiedUrl);
      fetchImageAndConvertToBase64(modifiedUrl, imgage2, name, id);
    }
  }

  void fetchImageAndConvertToBase64(String imageUrl, String image2, String name, String id) async {
    //   String imageUrl = 'https://websitedemoonline.com/facerecognition/uploads/65e9647a1180f.png';

    // Fetch the image
    http.Response response = await http.get(Uri.parse("https://"+imageUrl));
    Uri uri = Uri.parse(imageUrl);
    if (response.statusCode == 200) {
      // Convert the image bytes to Base64
      String image1 = base64Encode(response.bodyBytes);
      print('Base64 encoded image: $image1');

      var  body=jsonEncode(<String, String>{
        'image1': image1,
        'image2': image2,

      });
      var url = Urls.faceurl;
      print("res body" + url.toString());
      final responsess = await http.post(
          Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-RapidAPI-Key':Urls.rapid_key,
        'X-RapidAPI-Host': Urls.rapid_host
      },body: body);
      print("response" + responsess.body.toString());
      if (response.statusCode == 200) {
        print("vdbvsbd" );
       // var res = jsonDecode(response.body);
        var res = json.decode(responsess.body);
        print("vdbvsbd" + res.toString());
        if (res != null) {
          var info = res['data']['result'];
          print("ghfdhfd"+info.toString());

          if (info!="different") {
            UserData user = UserData(name, "", id);


            if (mounted) {
              _audioPlayer
                ..stop()
                ..setReleaseMode(ReleaseMode.release)
                ..play(AssetSource("sucessAttendance.m4r"));
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) =>
                      UserDetailsView(user: user,)),
              );
            }

          }
          else
            {
              CustomSnackBar.successSnackBar("No User Found", context);
            }

        }
      }
      else if (response.statusCode == 401) {
        print("data" + response.body.toString());

        // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
      }
      else if (response.statusCode == 500) {
        print("data" + response.body.toString());
      }
      else {
        print("data" + response.body.toString());
      }
    } else {
      print('Failed to fetch image: ${response.statusCode}');
    }
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
      // stackChildren.add(
      //   Positioned(
      //       top: 0.0,
      //       left: 0.0,
      //       width: size.width,
      //       height: size.height,
      //       child: buildResult()),
      // );
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
      body:  Stack(
          fit: StackFit.expand,
          children: [
            (controller.value.isInitialized)
                ? CameraPreview(controller)
                : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()))
          ]
      )
    );
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.faces);

  //final Size absoluteImageSize;
  final List<Face> faces;
//  CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    // final double scaleX = size.width / absoluteImageSize.width;
    // final double scaleY = size.height / absoluteImageSize.height;


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
