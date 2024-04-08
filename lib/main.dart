import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

import 'package:provider/provider.dart';

import 'package:realtime_face_recognition/Activity/SplashScreen.dart';
import 'package:realtime_face_recognition/Activity/faceapi.dart';

import 'package:realtime_face_recognition/Controller/BottomNavigationProvider.dart';
import 'package:realtime_face_recognition/Controller/CameraProvider.dart';
import 'package:realtime_face_recognition/Controller/ShowAttendaceDailyListController.dart';
import 'package:realtime_face_recognition/Controller/ShowStaffListProvider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// void main() => runApp(new MaterialApp(home: new MyAppssss()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider<BottomNavigationProvider>(create: (_) => BottomNavigationProvider()),
        ChangeNotifierProvider<ShowStaffListProvider>(create: (_) => ShowStaffListProvider()),
        ChangeNotifierProvider<CameraProvider>(create: (_) => CameraProvider()),
        ChangeNotifierProvider<ShowAttendanceList>(create: (_) => ShowAttendanceList()),

      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}




