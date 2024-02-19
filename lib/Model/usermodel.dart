import 'dart:convert';

class User {
  String user;

  List modelData;

  User({
    required this.user,

    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return new User(
      user: user['user'],

      modelData: jsonDecode(user['model_data']),
    );
  }


  factory User.fromJson(Map<String, dynamic> user) {
    return User(
      user: user['user'],
      modelData: jsonDecode(user['model_data']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'model_data': jsonEncode(modelData),
    };
  }

  toMap() {
    return {
      'user': user,
      'model_data': jsonEncode(modelData),
    };
  }

}
