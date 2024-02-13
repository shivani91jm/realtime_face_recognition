
import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/Model/Userattendancemodel.dart';
import 'package:realtime_face_recognition/main.dart';


class UserDetailsView extends StatefulWidget {
  final Recognition user;
  const UserDetailsView({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailsView> createState() => _UserDetailsViewState();
}

class _UserDetailsViewState extends State<UserDetailsView> {

  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    userprofileattendance();

    // _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    //   // Check if the state is still mounted before calling setState
    //   if (mounted) {
    //     setState(() {
    //
    //     });
    //   }
    // });
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

  void userprofileattendance() async{
    var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var namedate=widget.user.name+date;
    String formattedDate = DateFormat('HH:mm:ss').format(DateTime.now());
    print(""+formattedDate.toString());
    if(AppContents.status=="1") {
      UserAttendanceModel userAttendanceModel = UserAttendanceModel(
          name: widget.user.name.toString(),
          punch_in_time: formattedDate,
          punch_out_time: '');

      FirebaseFirestore.instance
          .collection("attendance")
          .doc(namedate)
          .set(userAttendanceModel.toJson())
          .catchError((e) {
        log("Inseted: $e");
        Navigator.of(context).pop();
      }).whenComplete(() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()),);
      });
    }
    else {
      FirebaseFirestore.instance
          .collection("attendance")
          .doc(namedate)
          .update({'punch_out_time' : formattedDate}) // <-- Nested value
          .then((_) =>
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()),))
          .catchError((error) => print('Failed: $error'));

    }
  }
}
