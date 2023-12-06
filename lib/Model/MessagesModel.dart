class MessagesHistory {
  List<Data>? data;

  MessagesHistory({this.data});

  MessagesHistory.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? userId;
  String? message;
  String? messageTime;

  Data({this.userId, this.message, this.messageTime});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    message = json['message'];
    messageTime = json['messageTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['userId'] = this.userId;
    data['message'] = this.message;
    data['messageTime'] = this.messageTime;
    return data;
  }
}

class UserMessages {
  String? userId;
  String? message;
  String? messageTime;

  UserMessages({this.userId, this.message, this.messageTime});

  UserMessages.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    message = json['message'];
    messageTime = json['messageTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['userId'] = this.userId;
    data['message'] = this.message;
    data['messageTime'] = this.messageTime;
    return data;
  }
}

class MyMessages {
  final String message;
  final String author;
  final String timestamp;

  MyMessages({required this.message, required this.author, required this.timestamp});
}