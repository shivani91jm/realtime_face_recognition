import 'dart:convert';

class UserAttendanceModel {
  var name;
  var punch_in_time;
  var punch_out_time;

  UserAttendanceModel({
     this.name,
     this.punch_in_time,
     this.punch_out_time,
  });

  static UserAttendanceModel fromMap(Map<String, dynamic> user) {
    return new UserAttendanceModel(
      name: user['name'],
        punch_in_time: user['punch_in_time'],
        punch_out_time: user['punch_out_time'],
    );
  }


  factory UserAttendanceModel.fromJson(Map<String, dynamic> user) {
    return UserAttendanceModel(
        name: user['name'],
        punch_in_time: user['punch_in_time'],
        punch_out_time: user['punch_out_time'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'punch_in_time':punch_in_time,
      'punch_out_time':punch_out_time
    };
  }

  toMap() {
    return {
      'name': name,
      'punch_in_time':punch_in_time,
      'punch_out_time':punch_out_time
    };
  }

}