import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/Controller/StaffListController.dart';
import 'package:realtime_face_recognition/DB/FirebaseService.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Model/usermodel.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../DB/DatabaseHelper.dart';
import 'Recognition.dart';
import 'package:http/http.dart' as http;
class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 112;
  static const int HEIGHT = 112;
  final dbHelper = DatabaseHelper();
  Map<String,Recognition> registered = Map();
  @override
  String get modelName => 'assets/mobile_face_net.tflite';
  final FirebaseService firebaseService = FirebaseService();
  List<Data>? users;
  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
    initDB();
  }

  initDB() async {
    await dbHelper.init();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var url= Urls.staffListUrl;
        print("res body"+url.toString());
        final response = await http.get(Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},);
        print("response"+response.body.toString());
        if (response.statusCode == 200) {

          StaffListModel res =StaffListModel.fromJson(jsonDecode(response.body));
          print("vdbvsbd"+res.toString());
          if(res!=null)
          {
            var info= res.success;

            if(info==true)
            {
              users=res.data;

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
    StaffListController controller=Get.put(StaffListController());
    controller.showStaffListController();
  // users=await firebaseService.fetchDataFromFirestore();


  }
  void loadRegisteredFaces() async {
    registered.clear();
    final allRows = await dbHelper.queryAllRows();
   // debugPrint('query all rows:');
   //  for (final row in allRows) {
   //  //  debugPrint(row.toString());
   //    print(row[DatabaseHelper.columnName]);
   //    String name = row[DatabaseHelper.columnName];
   //    List<double> embd = row[DatabaseHelper.columnEmbedding].split(',').map((e) => double.parse(e)).toList().cast<double>();
   //    Recognition recognition = Recognition(row[DatabaseHelper.columnName],Rect.zero,embd,0);
   //    registered.putIfAbsent(name, () => recognition);
   //    print("R="+name);
   //  }

  //  List<User> users = await firebaseService.fetchDataFromFirestore();
    for(int i=0;i<users!.length;i++)
      {
             String name = users![i].name.toString();
           // List<double> embd = users[i].modelData;
              List<double> embd = parseStringToList(users![i].faceModel);


             print(embd);
            Recognition recognition = Recognition(name,Rect.zero,embd,0,"false");
           registered.putIfAbsent(name, () => recognition);
            print("R="+name);
      }

  }
  List<double> parseStringToList(String str) {
    // Remove brackets [ and ]
    String numbersString = str.substring(1, str.length - 1);

    // Split the string by commas and parse each substring into a double
    List<double> numbers = numbersString.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();

    return numbers;
  }
  void registerFaceInDB(String name, List<double> embedding) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnEmbedding: embedding.join(",")
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    loadRegisteredFaces();
  }


  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage){
    img.Image resizedImage = img.copyResize(inputImage!, width: WIDTH, height: HEIGHT);
    List<double> flattenedList = resizedImage.data!.expand((channel) => [channel.r, channel.g, channel.b]).map((value) => value.toDouble()).toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int width = WIDTH;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] = (float32Array[c * height * width + h * width + w]-127.5)/127.5;
        }
      }
    }
    return reshapedArray.reshape([1,112,112,3]);
  }

  Recognition recognize(img.Image image,Rect location) {

    //TODO crop face from image resize it and convert it to float array
    var input = imageToArray(image);
    print(input.shape.toString());

    //TODO output array
    List output = List.filled(1*192, 0).reshape([1,192]);

    //TODO performs inference
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms$output');

    //TODO convert dynamic list to double list
     List<double> outputArray = output.first.cast<double>();

     //TODO looks for the nearest embeeding in the database and returns the pair
     Pair pair = findNearest(outputArray);
     print("distance= ${pair.distance}");

     return Recognition(pair.name,location,outputArray,pair.distance,pair.flag);
  }

  //TODO  looks for the nearest embeeding in the database and returns the pair which contain information of registered face with which face is most similar
  findNearest(List<double> emb){
    Pair pair = Pair("Unknown", -5,"false");
    for (MapEntry<String, Recognition> item in registered.entries) {
      final String name = item.key;
      List<double> knownEmb = item.value.embeddings;
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] -
            knownEmb[i];
        distance += diff*diff;
      }
      distance = sqrt(distance);
      if (pair.distance == -5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
      }
    }
    return pair;
  }

  void close() {
    interpreter.close();
  }

}
class Pair{
   String name;
   double distance;
   String flag;
   Pair(this.name,this.distance,this.flag);
}


