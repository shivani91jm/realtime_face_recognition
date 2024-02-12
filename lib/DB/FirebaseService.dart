import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_face_recognition/Model/usermodel.dart';


class FirebaseService {
  final CollectionReference customDataCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> addDataToFirestore(User data) async {
    await customDataCollection.add(data.toMap());
  }

  Future<List<User>> fetchDataFromFirestore() async {
    var snapshot = await customDataCollection.get();
    return snapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}