class TokenDataModel {
  String? agentVideoRoomAccessToken;
  String? agentScreenShareAccessToken;
  String? agentVideoCallUid;
  String? agentScreenShareUid;

  TokenDataModel({
  required String? agentVideoRoomAccessTokenValue,
  required String? agentScreenShareAccessTokenValue,
  required String? agentVideoCallUidValue,
  required String? agentScreenShareUidValue}
  ){
    agentVideoRoomAccessToken = agentVideoRoomAccessTokenValue;
    agentScreenShareAccessToken = agentScreenShareAccessTokenValue;
    agentVideoCallUid = agentVideoCallUidValue;
    agentScreenShareUid = agentScreenShareUidValue;
  }
}