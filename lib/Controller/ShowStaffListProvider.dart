import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Utils/Services.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
class ShowStaffListProvider extends ChangeNotifier{

  late StaffListModel data;
  bool loading = false;
  Services services = Services();
  getPostData(context) async {
    loading = true;
    data = await services.ShowStaffList(context);
    loading = false;
    notifyListeners();
  }
}