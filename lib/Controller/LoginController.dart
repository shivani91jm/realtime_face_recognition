import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController{
  RxBool isPasswordVisible = true.obs;
  BuildContext? context=Get.context;
  togglePasswordVisibility() async{
    isPasswordVisible.value=!isPasswordVisible.value;
  }

}