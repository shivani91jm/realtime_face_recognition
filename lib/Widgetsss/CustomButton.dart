import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_face_recognition/Utils/AppFontFamily.dart';
import 'package:realtime_face_recognition/Utils/Appcolors.dart';

class CustomButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  Color? colors;
  String? title;
  final  RxBool isLoading;
  CustomButton({Key?key,required this.onPressed,required this.title,required this.colors,required this.isLoading}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: colors,
      splashColor:Colors.blue,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,8.0),
          child: isLoading.value? Container(
            height: 13,
            width: 10,
            child: Center(

              child: CircularProgressIndicator(

                color: AppColors.whiteColors,

              ),
            ),
          ) : Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(title!,
              textAlign: TextAlign.center,
              style:AppFontFamilyClass.bold,

            ),
          ),
        ),
      ),
      onPressed: isLoading .value? null : onPressed,
      shape: const StadiumBorder(),
    );
  }
}