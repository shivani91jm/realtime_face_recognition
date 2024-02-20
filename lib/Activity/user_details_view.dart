
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:realtime_face_recognition/Controller/AttendanceController.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';



class UserDetailsView extends StatefulWidget {
  final Recognition user;
  const UserDetailsView({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailsView> createState() => _UserDetailsViewState();
}

class _UserDetailsViewState extends State<UserDetailsView> {

  Timer? _timer;
  AttendanceController controller=Get.put(AttendanceController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.attendanceController(widget.user.id.toString(),context);


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Authenticated!!!"),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff8D8AD3),
              Color(0xff454362),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xffFFFFFF),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xff55BD94),
                  child: Icon(
                    Icons.check,
                    color: Color(0xffFFFFFF),
                    size: 44,
                  ),
                ),
              ),
              SizedBox(height:50),
              Text(
                "Hey ${widget.user.name} !",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                  color: Color(0xffFFFFFF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You are Successfully Authenticated !",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Color(0xffFFFFFF).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
