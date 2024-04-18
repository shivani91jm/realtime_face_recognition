
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' hide Image;
import 'package:get/get.dart';

import 'package:path_provider/path_provider.dart';
import 'package:realtime_face_recognition/Controller/AttendanceController.dart';

import 'package:realtime_face_recognition/ML/Recognition.dart';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/ML/UserData.dart';

class UserDetailsView extends StatefulWidget {
  final UserData user;
  final image2;
  const UserDetailsView({Key? key, required this.user,this.image2}) : super(key: key);

  @override
  State<UserDetailsView> createState() => _UserDetailsViewState();
}

class _UserDetailsViewState extends State<UserDetailsView> {
  String _similarity = "nil";
  String _liveness = "nil";
   var image1 = new MatchFacesImage();
   var image2 = new MatchFacesImage();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  AttendanceController controller=Get.put(AttendanceController());
 // late Recognizer recognizer;
  List<MatchFacesImage> batchRequests = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // recognizer = Recognizer();

    controller.attendanceController(widget.user.id.toString(),context,widget.user.name.toString(),context);
   // faceRegonotion();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      )
    );
  }

  // void faceRegonotion() async{
  //
  //   var ur="https://"+widget.user.imageUrl;
  //    File userss=await urlToFile(ur);
  //    image1.bitmap = base64Encode(File(userss!.path).readAsBytesSync() );
  //   image1.imageType =  ImageType.PRINTED;
  //   Uint8List imges=  Uint8List.fromList(img.encodeBmp(widget.image2));
  //   String base64String = base64Encode(imges);
  //   image2.bitmap=base64String;
  //   image2.imageType=ImageType.PRINTED;
  //   if (image1.bitmap == null ||
  //       image1.bitmap == "" ||
  //       image2.bitmap == null ||
  //       image2.bitmap == "") return;
  //   setState(() => _similarity = "Processing...");
  //    var request = new MatchFacesRequest();
  //    request.images=[image1,image2];
  //     FaceSDK.matchFaces(jsonEncode(request)).then((value) {
  //       var response = MatchFacesResponse.fromJson(json.decode(value));
  //       FaceSDK.matchFacesSimilarityThresholdSplit(
  //           jsonEncode(response!.results), 0.75)
  //           .then((str) {
  //         var split = MatchFacesSimilarityThresholdSplit.fromJson(
  //             json.decode(str));
  //         setState(() => _similarity = split!.matchedFaces.length > 0
  //             ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
  //             "%")
  //             : "error");
  //         if (_similarity != "error" && double.parse(_similarity) > 90.00) {
  //           //print("hghg" + user.name);
  //           _audioPlayer
  //             ..stop()
  //             ..setReleaseMode(ReleaseMode.release)
  //             ..play(AssetSource("sucessAttendance.m4r"));
  //           // UserData data = UserData(
  //           //     user.name, image1.bitmap!, user.id, image2.bitmap!);
  //           print("R=dgfdgfd"+ widget.user.name);
  //
  //         }
  //       });
  //     });
  // }
  Future<File> urlToFile(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final imageName = 'my_image.png'; // Set a desired file name
    final appDir = await getApplicationDocumentsDirectory();
    final localPath = '${appDir.path}/$imageName';
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return imageFile;
  }

}


