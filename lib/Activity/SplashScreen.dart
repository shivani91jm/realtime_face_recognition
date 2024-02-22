import 'dart:async';
import 'package:flutter/material.dart';
import 'package:realtime_face_recognition/Activity/DashboardPage.dart';
import 'package:realtime_face_recognition/Activity/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 1), () async{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var admin_id= await prefs.getString('admin_id')??"";
      if(admin_id!="" && admin_id!="null")
        {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) =>
              const DashBoard()
              )
          );
        }
      else
        {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) =>
              const LoginPage()
              )
          );
        }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,

              colors: [Colors.blue,Colors.blue,]
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  "assets/images/logo_w.png",
                  height: 300.0,
                  width: 300.0,
                ),

              ],
            ),

            const CircularProgressIndicator(valueColor:  AlwaysStoppedAnimation<Color>(Colors.white),),
          ],
        ),
      ),
    );
  }
}
