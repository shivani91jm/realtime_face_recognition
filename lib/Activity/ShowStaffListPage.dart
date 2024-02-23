import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_face_recognition/Controller/ShowStaffListProvider.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
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
          color: Colors.white
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.network("https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg",height:80,width: 80,fit: BoxFit.cover,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(postMdl.data!.data![i].name!,style: TextStyle(
                          ),),
                        ],
                      ),
                    ),
                  ],
                )),
          );
        },
      )
        // Specify the provider to use and the data to listen to

      );

  }
}
