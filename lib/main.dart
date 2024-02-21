import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import 'package:provider/provider.dart';
import 'package:realtime_face_recognition/Activity/DashboardPage.dart';
import 'package:realtime_face_recognition/Activity/LoginPage.dart';
import 'package:realtime_face_recognition/Activity/SplashScreen.dart';
import 'package:realtime_face_recognition/Activity/StaffRecogniationPage.dart';
import 'package:realtime_face_recognition/Activity/StaffRegistrationPage.dart';
import 'package:realtime_face_recognition/Controller/BottomNavigationProvider.dart';
import 'package:realtime_face_recognition/Controller/ShowStaffListProvider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider<BottomNavigationProvider>(create: (_) => BottomNavigationProvider()),
        ChangeNotifierProvider<ShowStaffListProvider>(create: (_) => ShowStaffListProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}




