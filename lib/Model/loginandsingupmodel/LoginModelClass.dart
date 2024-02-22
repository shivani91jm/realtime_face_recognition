class LoginModelClass {
  bool? success;
  String? message;
  String? uid;
  String? email;

  LoginModelClass({this.success, this.message, this.uid, this.email});

  LoginModelClass.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    uid = json['uid'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['uid'] = this.uid;
    data['email'] = this.email;
    return data;
  }
}