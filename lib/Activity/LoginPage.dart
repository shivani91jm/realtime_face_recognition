import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_face_recognition/Widgetsss/TextInputFields.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //---------logo--------------
              Container(
                margin: EdgeInsets.fromLTRB(0, 40, 10, 10),
                height: 80,
                child: Image.asset("assets/images/logo_b.png",),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(25.0,0,0,0),
                child: Text("...........................................", style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("Welcome Back",
                      style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                        fontFamily: "Lexend"
                    ),
                    ),
                    Icon(Icons.waving_hand_sharp,color: Colors.yellow,)
                  ],
                ),
              ),
              Row(
                children: [
                  Text("to",
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("HR Attendance",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),),
                  )
                ],
              ),
              Text("Hello there, login to continue",
                style: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),),
              SizedBox(
                height: 20,
              ),
              // Form(
              //   key: formKey,
              //   child: Container(
              //     margin: EdgeInsets.all(20),
              //     child: Column(
              //       children: [
              //         TextInputFields(
              //           enable: true,
              //           controller: emailController,
              //           hintText: AppConstentData.Email,
              //           labelText:  AppConstentData.Email, isHint: false,
              //           nmber: TextInputType.emailAddress,
              //           bordercolors: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //           textcolors: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //           validator: (value) {
              //             if (value!.isEmpty) {
              //               return 'Enter email / username';
              //             } else if(!value.contains("@")){
              //               return "Enter valid email";
              //             }
              //             else{
              //               return null;
              //             }
              //           },),
              //         SizedBox(
              //           height: 20,
              //         ),
              //         PasswordTextEditWidget(
              //           enable: true,
              //           loginController: controller,
              //           controller: passwordController,
              //           hintText: AppConstentData.Password,
              //           labelText:  AppConstentData.Password,
              //           isHint: true.obs,
              //           nmber: TextInputType.visiblePassword,
              //           bordercolors:GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //           textcolors: GradientHelper.getColorFromHex(AppColors.RED_COLOR), validator: (value ) {
              //           if (value.toString().length < 3) {
              //             return 'Password should be longer or equal to 3 characters'.tr;
              //           } else {
              //             return null;
              //           }
              //         },
              //         ),
              //         SizedBox(
              //           height: 20,
              //         ),
              //         Obx(() =>  CustomButton(
              //           onPressed: () {
              //             if(formKey.currentState!.validate()){
              //               var email=emailController.text;
              //               var password=passwordController.text;
              //               controller.loginResponse(email,password);
              //             }
              //
              //           }, title: controller.loading.value?"Login": AppConstentData.Login,
              //           colors: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //           isLoading: controller.loading,
              //         ),),
              //         GestureDetector(
              //           onTap: () async {
              //             Navigator.pushNamed(context, RouteNames.forget_screen);
              //           },
              //           child: Padding(
              //             padding: const EdgeInsets.all(10.0),
              //             child: Align(
              //               alignment: Alignment.centerRight,
              //               child: Text(AppConstentData.forgetPassword,
              //                 style: TextStyle(
              //                   color: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //                   fontWeight: FontWeight.bold,
              //                   fontFamily: "Montserrat",
              //                 ),),
              //             ),
              //           ),
              //         ),
              //         SizedBox(height: 20,),
              //         Row(
              //           children: [
              //             Container(
              //               width: 150,
              //               child: Divider(
              //                 height: 2,
              //                 color: AppColors.greyColors,
              //                 thickness: 1,
              //
              //               ),
              //             ),
              //             Padding(
              //               padding: const EdgeInsets.all(8.0),
              //               child: Text("Or",
              //                 style: TextStyle(
              //                     color: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //                     fontWeight: FontWeight.bold,
              //                     fontFamily: "Montserrat",
              //                     fontSize: 18
              //                 ),),
              //             ),
              //             Expanded(
              //               child: Container(
              //                 width: 150,
              //                 child: Divider(
              //                   height: 2,
              //                   color: AppColors.greyColors,
              //                   thickness: 1,
              //
              //
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //         SizedBox(height: 50,),
              //         Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Container(
              //               decoration:  BoxDecoration(
              //                 color: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //                 borderRadius: BorderRadius.circular(25),
              //                 border: Border.all(
              //                   color: GradientHelper.getColorFromHex(AppColors.RED_COLOR) ,
              //                 ),
              //               ),
              //               child: GestureDetector(
              //                 onTap: (){
              //                   GoogleSinginClass.signup(context);
              //                 },
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(1.0),
              //                   child: CircleAvatar(
              //                     backgroundColor: AppColors.whiteColors,
              //                     child: Image.asset(
              //                         height: 20,
              //                         width: 20,
              //                         ImageUrls.google_url
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             SizedBox(
              //               width: 20,
              //             ),
              //             Container(
              //               decoration:  BoxDecoration(
              //                 color: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //                 borderRadius: BorderRadius.circular(25),
              //                 border: Border.all(
              //                   color: GradientHelper.getColorFromHex(AppColors.RED_COLOR) ,
              //                 ),
              //               ),
              //               child: GestureDetector(
              //                 onTap: () async{
              //                   FacebookSinginClass.facebooksignup(context);
              //                 },
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(1.0),
              //                   child: CircleAvatar(
              //                     backgroundColor: AppColors.whiteColors,
              //                     child: Image.asset(
              //                         height: 20,
              //                         width: 20,
              //                         ImageUrls.facebook_url
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //         SizedBox(
              //           height: 20,
              //         ),
              //         GestureDetector(
              //           onTap: () async {
              //             Navigator.pushNamed(context!,RouteNames.registration_screen);
              //           },
              //           child: Container(
              //             child: Row(
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Padding(
              //                   padding:  const EdgeInsets.fromLTRB(8,8.0,3.0,8.0),
              //                   child: Text(AppConstentData.noaccount,style: TextStyle(
              //                       color: AppColors.greyColors,
              //                       fontFamily: "Montserrat",
              //                       fontSize: AppSizeClass.maxSize16,
              //                       fontWeight: FontWeight.bold
              //                   ),),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.fromLTRB(0,8.0,8.0,8.0),
              //                   child: Text(AppConstentData.SignUp,style: TextStyle(
              //                       color: GradientHelper.getColorFromHex(AppColors.RED_COLOR),
              //                       fontFamily: "Montserrat",
              //                       fontWeight: FontWeight.bold,
              //                       fontSize: AppSizeClass.maxSize16
              //                   ),),
              //                 )
              //               ],
              //             ),
              //           ),
              //         ),
              //         SizedBox(
              //           height: 50,
              //         ),
              //
              //       ],
              //     ),
              //   ),
              // )
          
            ],
          ),
        ),
      ),
    );
  }
}
