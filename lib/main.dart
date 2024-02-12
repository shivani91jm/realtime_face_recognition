import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/Activity/StaffRecogniationPage.dart';
import 'package:realtime_face_recognition/Activity/StaffRegistrationPage.dart';

late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(cameras: cameras,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  late List<CameraDescription> cameras;
  MyHomePage({Key? key, required this.cameras}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

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

}


