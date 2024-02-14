import 'dart:convert';

class UserAttendanceModel {
  var name;
  var punch_in_time;
  var punch_out_time;
  var flag;

  UserAttendanceModel({
     this.name,
     this.punch_in_time,
     this.punch_out_time,
    this.flag,
  });

  static UserAttendanceModel fromMap(Map<String, dynamic> user) {
    return new UserAttendanceModel(
      name: user['name'],
        punch_in_time: user['punch_in_time'],
        punch_out_time: user['punch_out_time'],
      flag: user['flag'],
    );
  }


  factory UserAttendanceModel.fromJson(Map<String, dynamic> user) {
    return UserAttendanceModel(
        name: user['name'],
        punch_in_time: user['punch_in_time'],
        punch_out_time: user['punch_out_time'],
          flag: user['flag'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'punch_in_time':punch_in_time,
      'punch_out_time':punch_out_time,
      'flag':flag,
    };
  }

  toMap() {
    return {
      'name': name,
      'punch_in_time':punch_in_time,
      'punch_out_time':punch_out_time,
      'flag':flag
    };
  }

}