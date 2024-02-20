import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realtime_face_recognition/Activity/StaffRecogniationPage.dart';
import 'package:realtime_face_recognition/Activity/StaffRegistrationPage.dart';
class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('SETTINGS', style: TextStyle(
            color: Colors.white
        ),),
      ),
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
                }, child: Text("Attendance")
            )
          ],
        ),
      ),

    );
  }
  void camerapermission() async {
    // final status = await permissionCamera.request();
    // if (status.isGranted) {
    //   // Open the camera
    //   print('Opening camera...');
    //
    // } else {
    //   // Permission denied
    //   print('Camera permission denied.');
    // }
    // final status2 = await permissionAudio.request();
    // if (status2.isGranted) {
    //   // Open the camera
    //   print('Opening camera...');
    // } else {
    //   // Permission denied
    //   print('Camera permission denied.');
    // }
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
    }
  }
}