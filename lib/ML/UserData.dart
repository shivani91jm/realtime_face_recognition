import 'dart:ui';
class UserData{

  String? id;
  String? name;
  String? image;
  // FaceFeatures? faceFeatures;
  String? staffId;
  int? registeredOn;

  UserData({
  this.id,
  this.name,
  this.image,
  //  this.faceFeatures,
  this.staffId,
  this.registeredOn,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
  return UserData(
  id: json['id'],
  name: json['name'],
  image: json['image'],
  //  faceFeatures: FaceFeatures.fromJson(json["faceFeatures"]),
  staffId: json['staffId'],
  registeredOn: json['registeredOn'],
  );
  }

  Map<String, dynamic> toJson() {
  return {
  'id': id,
  'name': name,
  'image': image,
  //  'faceFeatures': faceFeatures?.toJson() ?? {},
  'staffId':staffId,
  'registeredOn': registeredOn,
  };
  }
  }




