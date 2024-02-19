class Data {
  String? id;
  String? name;
  var faceModel;
  String? registrationDate;
  String? registrationTime;

  Data(
      {this.id,
        this.name,
        this.faceModel,
        this.registrationDate,
        this.registrationTime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    faceModel = json['face_model'];
    registrationDate = json['registration_date'];
    registrationTime = json['registration_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['face_model'] = this.faceModel;
    data['registration_date'] = this.registrationDate;
    data['registration_time'] = this.registrationTime;
    return data;
  }
}