import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:realtime_face_recognition/Activity/StaffRecogniationPage.dart';
import 'package:realtime_face_recognition/Activity/StaffRegistrationPage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final permissionCamera = Permission.camera;
  final permissionAudio= Permission.audio;
  late List<CameraDescription> cameras;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    camerapermission();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  StaffRegistrationPage(cameras: cameras,)),);
            }, child: Text("Registration")
            ),
            ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  StaffRecognationPage(cameras: cameras,)),);
            }, child: Text("Recognition")
            )
          ],
        ),
      ),

    );
  }
  void camerapermission() async{
    final status = await permissionCamera.request();
    if (status.isGranted) {
      // Open the camera
      print('Opening camera...');
      try {
        cameras = await availableCameras();
      } on CameraException catch (e) {
        print('Error: $e.code\nError Message: $e.message');
      }
    } else {
      // Permission denied
      print('Camera permission denied.');
    }
    final status2 = await permissionAudio.request();
    if (status2.isGranted) {
      // Open the camera
      print('Opening camera...');
    } else {
      // Permission denied
      print('Camera permission denied.');
    }
  }
}


