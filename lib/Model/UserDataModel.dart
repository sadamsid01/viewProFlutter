class UserDataModel {
  bool? success;
  String? agentId;
  String? agentName;
  String? agentAccessToken;
  String? agentRefreshToken;
  String? agentImage;
  String? agentAvatar;

  UserDataModel(
      {this.success, this.agentAccessToken, this.agentRefreshToken,
        this.agentId, this.agentName, this.agentImage, this.agentAvatar});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    agentId = json['id'];
    agentAccessToken = json['accessToken'];
    agentRefreshToken = json['refreshToken'];
    agentName = json['agentName'];
    agentImage = json['image'];
    agentAvatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = success;
    data['id'] = agentId;
    data['accessToken'] = agentAccessToken;
    data['refreshToken'] = agentRefreshToken;
    data['agentName'] = agentName;
    data['image'] = agentImage;
    data['avatar'] = agentAvatar;
    return data;
  }
}