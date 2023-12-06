import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Model/DataForCallModel.dart';
import '../Model/MessagesModel.dart';
import '../Model/TokenDataModel.dart';
import '../Model/UserDataModel.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
  encryptedSharedPreferences: true,
);

class MyStorage {
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  static Future<void> clearAll() async {
    await secureStorage.deleteAll();
  }

  static Future<void> setString(String key,String value) async {
    await secureStorage.write(key: key, value: value);
  }

  static Future<String?> getString(String key) async {
    return await secureStorage.read(key: key);
  }

  static Future<void> setBool(String key,bool value) async {
    await secureStorage.write(key: key, value: value.toString());
  }

  static Future<bool?> getBool(String key) async {
    String? value = await secureStorage.read(key: key);
    return bool.fromEnvironment(value!);
  }

  static Future<void> removeString(String key) async {
    await secureStorage.delete(key: key);
  }

  static Future<void> setAccessToken(String agentAccessToken) async {
    await secureStorage.write(key: 'agentAccessToken', value: agentAccessToken);
  }

  static Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'agentAccessToken');
  }

  static Future<bool?> checkForAccessToken() async {
    var accessToken = await secureStorage.read(key: 'agentAccessToken');
    if(accessToken != null) {
      if(accessToken!.isEmpty) {
        return false;
      }
      else if(accessToken!.isNotEmpty) {
        return true;
      }
    }
    return null;
  }

  static Future<void> setPreviousCallStatus(String previousCallStatus) async {
    await secureStorage.write(key: 'previousCallStatus', value: previousCallStatus);
  }

  static Future<bool?> checkForPreviousCallStatus() async {
    var previousCallStatus = await secureStorage.read(key: 'previousCallStatus');
    if(previousCallStatus != null) {
      if(previousCallStatus == "Yes") {
        return true;
      }
      else if(previousCallStatus == "No") {
        return false;
      }
    }
    return false;
  }

  static Future<void> setAgentId(String agentId) async {
    await secureStorage.write(key: 'agentId', value: agentId);
  }

  static Future<String?> getAgentId() async {
    return await secureStorage.read(key: 'agentId');
  }

  static Future<void> setCallStatus(String callStatus) async {
    await secureStorage.write(key: 'callStatus', value: callStatus);
  }


  static Future<bool?> checkForCallRingingStatus() async {
    var callStatus = await secureStorage.read(key: 'callStatus');
    if (callStatus != null && callStatus == "OnPending") {
      return true;
    }
    return false;
  }
  static Future<bool?> checkForCallStatus() async {
    var callStatus = await secureStorage.read(key: 'callStatus');
    if(callStatus != null) {
      if(callStatus == "OnCall") {
        return false;
      }
      else if(callStatus == "OnPending") {
        return false;
      }
      else if(callStatus == "OnActive") {
        return true;
      }
      else if(callStatus == "OnOffline") {
        return false;
      }
    }
    return true;
  }

  static Future<void> setCallType(String callType) async {
    await secureStorage.write(key: 'callType', value: callType);
  }

  static Future<bool?> checkForCallType() async {
    var callType = await secureStorage.read(key: 'callType');
    if(callType != null) {
      if(callType == "New") {
        return true;
      }
      else if(callType == "Transfer") {
        return false;
      }
    }
    return true;
  }

  static Future<void> setDataOfUser(UserDataModel data) async {
    final jsonString = jsonEncode(data.toJson());
    await secureStorage.write(key: 'myUserData', value: jsonString);
  }

  static Future<UserDataModel?> getDataOfUser() async {
    final jsonString = await secureStorage.read(key: 'myUserData');
    if (jsonString != null) {
      final dataMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserDataModel.fromJson(dataMap);
    }
    return null;
  }

  static Future<void> setDataForCall(DataForCall data) async {
    final jsonString = jsonEncode(data.toJson());
    await secureStorage.write(key: 'myDataForCall', value: jsonString);
  }

  static Future<DataForCall?> getDataForCall() async {
    final jsonString = await secureStorage.read(key: 'myDataForCall');
    if (jsonString != null) {
      final dataMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return DataForCall.fromJson(dataMap);
    }
    return null;
  }

  static Future<void> setMessagesHistoryData(MessagesHistory data) async {
    final jsonString = jsonEncode(data.toJson());
    await secureStorage.write(key: 'myMessagesHistoryData', value: jsonString);
  }

  static Future<MessagesHistory?> getMessagesHistoryData() async {
    final jsonString = await secureStorage.read(key: 'myMessagesHistoryData');
    if (jsonString != null) {
      final dataMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return MessagesHistory.fromJson(dataMap);
    }
    return null;
  }

  static Future<void> setDataForToken(TokenDataModel tokenData) async {
    await secureStorage.write(key: 'myDataForToken_agentVideoRoomAccessToken',
        value: tokenData.agentVideoRoomAccessToken ?? '');
    await secureStorage.write(key: 'myDataForToken_agentScreenShareAccessToken',
        value: tokenData.agentScreenShareAccessToken ?? '');
    await secureStorage.write(key: 'myDataForToken_agentVideoCallUid',
        value: tokenData.agentVideoCallUid.toString() ?? '');
    await secureStorage.write(key: 'myDataForToken_agentScreenShareUid',
        value: tokenData.agentScreenShareUid.toString() ?? '');
  }

  static Future<void> clearDataForToken() async {
    await secureStorage.delete(key: 'myDataForToken_agentVideoRoomAccessToken');
    await secureStorage.delete(key: 'myDataForToken_agentScreenShareAccessToken');
    await secureStorage.delete(key: 'myDataForToken_agentVideoCallUid');
    await secureStorage.delete(key: 'myDataForToken_agentScreenShareUid');
  }

  static Future<TokenDataModel?> getDataForToken() async {
    final videoRoomAccessToken = await secureStorage.read(key: 'myDataForToken_agentVideoRoomAccessToken');
    final screenShareAccessToken = await secureStorage.read(key: 'myDataForToken_agentScreenShareAccessToken');
    final agentVideoCallUid = await secureStorage.read(key: 'myDataForToken_agentVideoCallUid');
    final agentScreenShareUid = await secureStorage.read(key: 'myDataForToken_agentScreenShareUid');
    if (videoRoomAccessToken != null && screenShareAccessToken != null) {
      return TokenDataModel(
          agentVideoRoomAccessTokenValue: videoRoomAccessToken,
          agentScreenShareAccessTokenValue: screenShareAccessToken,
          agentVideoCallUidValue: agentVideoCallUid,
          agentScreenShareUidValue: agentScreenShareUid);
    }
    return null;
  }

}