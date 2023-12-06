class AgentDataModel {
  String? agentId;
  String? name;
  int? age;
  String? phoneno;
  String? password;
  String? email;
  String? workspaceId;
  String? type;
  int? iV;
  String? agentImage;
  String? agentAvatar;

  AgentDataModel(
      {this.agentId,
        this.name,
        this.age,
        this.phoneno,
        this.password,
        this.email,
        this.workspaceId,
        this.type,
        this.iV,
        this.agentImage,
        this.agentAvatar});

  AgentDataModel.fromJson(Map<String, dynamic> json) {
    agentId = json['_id'];
    name = json['name'];
    age = json['age'];
    phoneno = json['phoneno'];
    password = json['password'];
    email = json['email'];
    workspaceId = json['workspaceId'];
    type = json['type'];
    iV = json['__v'];
    agentImage = json['image'];
    agentAvatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.agentId;
    data['name'] = this.name;
    data['age'] = this.age;
    data['phoneno'] = this.phoneno;
    data['password'] = this.password;
    data['email'] = this.email;
    data['workspaceId'] = this.workspaceId;
    data['type'] = this.type;
    data['__v'] = this.iV;
    data['image'] = agentImage;
    data['avatar'] = agentAvatar;
    return data;
  }
}

class ActiveAgentDataModel {
  String id;

  ActiveAgentDataModel(this.id);

  factory ActiveAgentDataModel.fromJson(Map<String, dynamic> json) {
    return ActiveAgentDataModel(json['data'].toString());
  }
}