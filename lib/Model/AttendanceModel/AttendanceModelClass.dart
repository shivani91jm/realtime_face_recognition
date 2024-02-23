class AttendanceModelClass {
  String? id;
  String? name;
  String? punchIn;
  String? punchOut;
  String? date;

  AttendanceModelClass(
      {this.id, this.name, this.punchIn, this.punchOut, this.date});

  AttendanceModelClass.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['Name'];
    punchIn = json['punch_in'];
    punchOut = json['punch_out'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Name'] = this.name;
    data['punch_in'] = this.punchIn;
    data['punch_out'] = this.punchOut;
    data['date'] = this.date;
    return data;
  }
}