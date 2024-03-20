import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/Controller/AttendanceController.dart';
import 'package:realtime_face_recognition/DB/FirebaseService.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Model/usermodel.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../DB/DatabaseHelper.dart';
import 'Recognition.dart';
import 'package:http/http.dart' as http;


class Recognizer222 {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 112;
  static const int HEIGHT = 112;
  double threshold = 1.5;
  final dbHelper = DatabaseHelper();
  Map<String, Recognition> registered = Map();

  @override
  String get modelName => 'assets/mobile_face_net.tflite';
  final FirebaseService firebaseService = FirebaseService();
  List<Data>? users;
  List<double>? predictedArray;

  Recognizer222({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }

    initDB();
  }

  initDB() async {
    await dbHelper.init();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var admin_id = await prefs.getString('admin_id') ?? "";
        var url = Urls.staffListUrl + "admin_id=${admin_id}";
        print("res body" + url.toString());
        final response = await http.get(
          Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},);
        print("response" + response.body.toString());
        if (response.statusCode == 200) {
          StaffListModel res = StaffListModel.fromJson(
              jsonDecode(response.body));
          print("vdbvsbd" + res.toString());
          if (res != null) {
            var info = res.success;

            if (info == true) {
              users = res.data;
            }
            loadRegisteredFaces();
          }
        }
        else if (response.statusCode == 401) {
          print("data" + response.body.toString());

          // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
        }
        else if (response.statusCode == 500) {
          print("data" + response.body.toString());
        }
        else {
          print("data" + response.body.toString());
        }
      }
    }
    on SocketException catch (_) {

    }
  }

  void loadRegisteredFaces() async {
    registered.clear();
    for (int i = 0; i < users!.length; i++) {
      String name = users![i].name.toString();
      var url = users![i].faceModel;
      String modifiedUrl = url.replaceFirst(
          '\/home\/hqcj8lltjqyi\/public_html\/', '');
      print(modifiedUrl);
      fetchImageAndConvertToBase64(modifiedUrl,"");
    }
  }

  void fetchImageAndConvertToBase64(String imageUrl,String image2) async {
 //   String imageUrl = 'https://websitedemoonline.com/facerecognition/uploads/65e9647a1180f.png';

    // Fetch the image
    http.Response response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // Convert the image bytes to Base64
      String image1 = base64Encode(response.bodyBytes);
      print('Base64 encoded image: $image1');

    var  body=jsonEncode(<String, String>{
        'image1': image1,
        'image2': image2,

      });
      var url = Urls.faceurl;
      print("res body" + url.toString());
      final responsess = await http.post(
        Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'X-RapidAPI-Key':Urls.rapid_key,
        'X-RapidAPI-Host': Urls.rapid_host
      },body: body);
      print("response" + responsess.body.toString());
      if (response.statusCode == 200) {
        StaffListModel res = StaffListModel.fromJson(
            jsonDecode(response.body));
        print("vdbvsbd" + res.toString());
        if (res != null) {
          var info = res.success;

          if (info == true) {
            users = res.data;
          }
          loadRegisteredFaces();
        }
      }
      else if (response.statusCode == 401) {
        print("data" + response.body.toString());

        // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
      }
      else if (response.statusCode == 500) {
        print("data" + response.body.toString());
      }
      else {
        print("data" + response.body.toString());
      }


    } else {
      print('Failed to fetch image: ${response.statusCode}');
    }
  }
}
class Pair{
  String name;
  double distance;
  String id;
  Pair(this.name,this.distance,this.id);
}


