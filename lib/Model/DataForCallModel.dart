class DataForCall {
  String? agentId;
  String? userSid;
  int? clientUid;
  String? appId;
  String? appCertificate;
  String? channelName;

  DataForCall({this.appId, this.userSid, this.clientUid ,this.agentId, this.appCertificate, this.channelName});

  DataForCall.fromJson(Map<String, dynamic> json) {
    agentId = (json['agentId'] != null)?json['agentId']:"";
    userSid = json['userSid'];
    clientUid = (json['clientUid'] != null)?json['clientUid']:0;
    appId = json['appId'];
    appCertificate = json['appCertificate'];
    channelName = json['channelName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['userSid'] =  userSid;
    data['clientUid'] =  clientUid;
    data['appId'] = appId;
    data['appCertificate'] = appCertificate;
    data['channelName'] = channelName;
    return data;
  }
}