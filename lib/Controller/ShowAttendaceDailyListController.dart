import 'package:flutter/material.dart';
import 'package:realtime_face_recognition/Model/AttendanceModel/AttendanceModelClass.dart';
import 'package:realtime_face_recognition/Utils/Services2.dart';

class ShowAttendanceList extends ChangeNotifier{

  late List<AttendanceModelClass> data=[];
  bool loading = false;
  Service2 services = Service2();
  getData(context) async {
    loading = true;
    data = await services.ShowAttendanceList(context);
    loading = false;
    notifyListeners();
  }
}

