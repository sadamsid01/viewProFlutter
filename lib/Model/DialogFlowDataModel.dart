class QueryData {
  String? success;
  List<String>? dialogFlow;

  QueryData({this.success, this.dialogFlow});

  QueryData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    dialogFlow = json['DialogFlow'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['DialogFlow'] = this.dialogFlow;
    return data;
  }
}