import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_face_recognition/Activity/StaffDetailsPage.dart';
import 'package:realtime_face_recognition/Controller/ShowStaffListProvider.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Utils/AppFontFamily.dart';
import 'package:realtime_face_recognition/Widgetsss/CommonWidget.dart';
class ShowStaffListPage extends StatefulWidget {
  const ShowStaffListPage({super.key});
  @override
  State<ShowStaffListPage> createState() => _ShowStaffListPageState();
}

class _ShowStaffListPageState extends State<ShowStaffListPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<ShowStaffListProvider>(context, listen: false).getPostData(context);
  }
  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<ShowStaffListProvider>(context);
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('STAFF LIST', style: TextStyle(
          color: Colors.white,

        ),),
      ),
      body:  postMdl.loading
          ?  Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (ctx,i){
              return Column(
                children: [
                  loadingShimmer(),
                  const SizedBox(height: 10,)
                ],
              );
            }),
      )
          :  ListView.builder(
        itemCount: postMdl.data!.data!.length,
        itemBuilder: (context, i) {
          return Container(
            margin: EdgeInsets.all(5),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  StaffDetailsPage()),
                );
              },
              child: Card(
                  child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              alignment: Alignment.center,
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.0),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          "https://images.unsplash.com/1/iphone-4-closeup.jpg?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
                                        ), fit: BoxFit.cover)
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(postMdl.data!.data![i].name!,
                                      style: AppFontFamilyClass.blackebold,
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),

                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          iconSize: 18,
                          splashColor: Colors.blue ,
                          icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                          onPressed: () async
                          {

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  StaffDetailsPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          );
        },
      )
        // Specify the provider to use and the data to listen to

      );

  }
}
