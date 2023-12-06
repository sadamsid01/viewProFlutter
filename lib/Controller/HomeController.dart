// ignore_for_file: file_names, library_prefixes
// import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:convert';
import 'dart:async';

import '../Model/DataForCallModel.dart';
import '../Model/TokenDataModel.dart';
import '../Model/UserDataModel.dart';
import '../Model/MessagesModel.dart';
import '../Model/NoteModel.dart';
import '../Utilities/SecureStorage.dart';
import '../Utilities/AppConstants.dart';
import '../Utilities/SocketConstants.dart';
import '../View/CallView.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
  encryptedSharedPreferences: true,
);

class HomeController extends GetxController {
  int selectedIndex = 0;

  DataForCall? myDataForCall = DataForCall();

  TokenDataModel? myTokenData;

  UserDataModel? myUserData = UserDataModel();

  MessagesHistory? myMessagesHistory = MessagesHistory();

  //TodoAppWorking
  final RxList<Note> notes = <Note>[].obs;
  FlutterSecureStorage todoStorageBucket = FlutterSecureStorage(aOptions: _getAndroidOptions());

  RxBool? loadingData = false.obs;

  @override
  onInit(){
    if (kDebugMode) {
      print("onInit");
    }
    getMyDataFromMyStorage();
   // checkForPreviousCall();
    initSocket();
    loadNotes();
    listenerEvent(onEvent);
    super.onInit();
  }

  checkForPreviousCall() async {
    var checkForPreviousCallStatus = await MyStorage.checkForPreviousCallStatus();
    myDataForCall = await MyStorage.getDataForCall();
    if(checkForPreviousCallStatus == true && myDataForCall != null){
      loadingData?.toggle();
      myTokenData = await MyStorage.getDataForToken();
      if (kDebugMode) {
          print("MyDataForCall: $myDataForCall");
          print("MyTokenData: $myTokenData");
        }
        loadingData?.toggle();
        if(myDataForCall != null && myTokenData != null){
          joinCall();
        }
      }
    else {
      if (kDebugMode) {
        print("No Previous Call Found");
      }
    }
  }

  Future<void> initSocket() async {
    var checkForInitSocketStatus = await SocketConstants.initSocket();
    if(checkForInitSocketStatus){
      if (kDebugMode) {
        print("checkForInitSocketStatus at Home: $checkForInitSocketStatus");
      }
    }
    SocketConstants.socket!.connect();
    SocketConstants.socket!.onConnect((_) {
      if (kDebugMode) {
        print('Socket is ReConnected at Home');
      }
    });
    Future.delayed(const Duration(seconds: 5), () {
      //SocketConnectionCheck
      if(SocketConstants.socket!.connected) {
        if (kDebugMode) {
          print('Socket is Connected at the Moment at Home');
        }
      }
      else if (SocketConstants.socket!.disconnected) {
        if (kDebugMode) {
          print('Socket is Not Connected at the Moment at Home');
        }
      }
    });
  }

  getMyDataFromMyStorage() async {

    myUserData = await MyStorage.getDataOfUser();
    if (kDebugMode) {
      print("MyUserDataModel: $myUserData");
    }
    loadingData?.toggle();
  }

  Future<void> loadNotes() async {
    loadingData?.toggle();
    final noteStrings = await todoStorageBucket.read(key: 'notes') ?? '[]';
    notes.value = (jsonDecode(noteStrings) as List<dynamic>)
        .map((note) => Note.fromMap(Map<String, dynamic>.from(note)))
        .toList();
  }

  Future<void> addNote(Note note) async {
    int id = int.tryParse(await todoStorageBucket.read(key: 'lastNoteId') ?? '0') ?? 0;
    id++;
    final newNote = Note(
      id: id,
      title: note.title,
      description: note.description,
    );

    notes.add(newNote);

    await todoStorageBucket.write(
      key: 'notes',
      value: jsonEncode(notes.map((note) => note.toMap()).toList()),
    );

    await todoStorageBucket.write(key: 'lastNoteId', value: id.toString());
  }

  Future<void> updateNoteById(Note thisNote) async {
    final noteIndex = notes.indexWhere((note) => note.id == thisNote.id);

    if (noteIndex != -1) {
      final updatedNote = notes[noteIndex].copyWith(
        title: thisNote.title,
        description: thisNote.description,
      );
      notes[noteIndex] = updatedNote;

      await todoStorageBucket.write(
        key: 'notes',
        value: jsonEncode(notes.map((note) => note.toMap()).toList()),
      );
    }
  }

  Future<void> deleteNoteById(int id) async {
    final noteIndex = notes.indexWhere((note) => note.id == id);

    if (noteIndex != -1) {
      notes.removeAt(noteIndex);

      await todoStorageBucket.write(
        key: 'notes',
        value: jsonEncode(notes.map((note) => note.toMap()).toList()),
      );
    }
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    update();
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print("onClose");
    }
    super.onClose();
  }

  joinCall() async {
    Get.to(
        CallView(
        myUserData: myUserData!,
        myDataForCall: myDataForCall!,
        myTokenData: myTokenData!
    ));
  }

  Future<String?> getAccessTokenFromAgora(String? userUid, String? myChannelName) async {
    final body = jsonEncode({
      'userUid': userUid,
      'channelName': myChannelName,
      'role': 0,
    });

    if (kDebugMode) {
      print("Body: $body");
    }

    final response = await http.post(
      Uri.parse("${AppConstants.appURL}/agoraToken"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${myUserData!.agentAccessToken}',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (kDebugMode) {
        print("StatusCode: ${response.statusCode}");
        print("Result: $data");
      }

      final String? generatedAccessToken = data['tokenA'] as String?;

      if (kDebugMode) {
        print("generatedAccessToken: $generatedAccessToken");
      }

      return generatedAccessToken;
    }

    return null;
  }

  callAccept() async {
    loadingData?.toggle();
    update();
    myDataForCall = await MyStorage.getDataForCall();
    if (kDebugMode) {
      print("MyDataForCall: $myDataForCall");
    }
    var checkForCallType = await MyStorage.checkForCallType();

    var agentVideoCallUid = Random().nextInt(1000);
    var agentScreenShareUid = (agentVideoCallUid)!+1;
    var videoAccessToken = await getAccessTokenFromAgora(
        agentVideoCallUid.toString(),
        myDataForCall!.channelName);
    var screenShareAccessToken = await getAccessTokenFromAgora(
        agentScreenShareUid.toString(),
        myDataForCall!.channelName);
    myTokenData = TokenDataModel(
        agentVideoRoomAccessTokenValue: videoAccessToken,
        agentScreenShareAccessTokenValue: screenShareAccessToken,
        agentVideoCallUidValue: agentVideoCallUid.toString(),
        agentScreenShareUidValue: agentScreenShareUid.toString());
    MyStorage.setDataForToken(myTokenData!);

    if(videoAccessToken != null && screenShareAccessToken != null){
      if(checkForCallType! == true) {
        var myData = jsonEncode({
          //Code Added
          'videoUid': agentVideoCallUid,
          'userSid': myDataForCall!.userSid,
          'agentId': myUserData!.agentId,
          'agentName': myUserData!.agentName,
          'avatar': myUserData!.agentAvatar,
          'image': myUserData!.agentImage
        });
        if (kDebugMode) {
          print("MyData: $myData");
        }
        if(SocketConstants.socket!.connected) {
          if (kDebugMode) {
            print("Socket is Connected");
          }
        }
        else if(SocketConstants.socket!.disconnected) {
          if (kDebugMode) {
            print("Socket is Not Connected");
          }
          SocketConstants.socket!.connect();
          if(SocketConstants.socket!.connected) {
            if (kDebugMode) {
              print("Socket is Now Connected");
            }
          }
        }
        var checkForCallStatus = await MyStorage.checkForCallStatus();
        if (kDebugMode) {
          print("CheckForCallStatus Before CallAcceptEvent: $checkForCallStatus");
        }
        if(checkForCallStatus == false){
          SocketConstants.socket!.emit("AgentCallAccept",myData);
          SocketConstants.socket!.on("CallEstablished", (data) async {
            if (kDebugMode) {
              print("Payload: $data");
              print("3 Way Handshake Complete");
              loadingData?.value = false;
              update();
              SocketConstants.socket!.emit("callPick",data);
              joinCall();
            }});
        }
        else if(checkForCallStatus == true){
          loadingData?.value = false;
          update();
        }
      }
      else if(checkForCallType! == false) {
        var myData = jsonEncode({
          //Code Added
          'videoUid': agentVideoCallUid,
          'userSid': myDataForCall!.userSid,
          'agentId': myUserData!.agentId,
          'agentName': myUserData!.agentName,
          'avatar': myUserData!.agentAvatar,
          'image': myUserData!.agentImage
        });
        if (kDebugMode) {
          print("MyData: $myData");
          print("Call Transfer");
        }
        if (SocketConstants.socket!.connected) {
          if (kDebugMode) {
            print("Socket is Connected");
          }
        }
        else if (SocketConstants.socket!.disconnected) {
          if (kDebugMode) {
            print("Socket is Not Connected");
          }
          SocketConstants.socket!.connect();
          if (SocketConstants.socket!.connected) {
            if (kDebugMode) {
              print("Socket is Now Connected");
            }
          }
        }
        var checkForCallStatus = await MyStorage.checkForCallStatus();
        if (kDebugMode) {
          print("CheckForCallStatus Before CallAcceptEvent: $checkForCallStatus");
        }
        if(checkForCallStatus == false){
          SocketConstants.socket!.emit("agentAcceptTransferCall",myData);
          var myDataForChatHistory = jsonEncode({
            'agentSid': myUserData!.agentId,
            'userSid': myDataForCall!.userSid,
            'videoUid': agentVideoCallUid!.toString()
          });
          if (kDebugMode) {
            print("MyDataForChatHistory: $myDataForChatHistory");
            print("Call Transfer");
          }
          SocketConstants.socket!.emit("chatHistory",myDataForChatHistory);
          if(SocketConstants.socket!.connected) {
            if (kDebugMode) {
              print("Socket is Connected");
            }
            SocketConstants.socket!.on("chatHistoryReceived", (data) async {
              if (kDebugMode) {
                print("ChatHistoryReceived Data: $data");
              }
              myMessagesHistory = MessagesHistory.fromJson(data);
              if (kDebugMode) {
                print("MessagesList: $myMessagesHistory");
              }
              MyStorage.setMessagesHistoryData(myMessagesHistory!);
            });
          }
          else if(SocketConstants.socket!.disconnected) {
            if (kDebugMode) {
              print("Socket is Not Connected");
            }
            SocketConstants.socket!.connect();
            if(SocketConstants.socket!.connected) {
              if (kDebugMode) {
                print("Socket is Now Connected");
              }
            }
          }
          SocketConstants.socket!.on("agentTransferCallEstablished", (data) async {
            if (kDebugMode) {
              print("Payload: $data");
              print("3 Way Handshake Complete");
              loadingData?.value = false;
              update();
              SocketConstants.socket!.emit("callPick",data);
              joinCall();
            }});
        }
        else if(checkForCallStatus == true){
          myDataForCall = null;
          await MyStorage.removeString("myDataForCall");
          loadingData?.value = false;
          update();
        }
      }
      else {
        Get.snackbar("Call Failed", "Unable to do Handshake");
      }
    }
  }

  callDecline() async {
    await MyStorage.setCallStatus("OnActive");
    if (kDebugMode) {
      print("Call Status: OnActive");
    }
  }

  Future<void> listenerEvent(Function? callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        if (kDebugMode) {
          print('HOME: $event');
        }
        switch (event!.event) {
          case Event.actionCallAccept:
          // TODO: accepted an incoming call
            await callAccept();
            break;
          case Event.actionCallDecline:
          // TODO: declined an incoming call
            await callDecline();
            break;
          case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
            await callDecline();
            break;
          case Event.actionCallTimeout:
          // TODO: missed an incoming call
            await callDecline();
            break;
        }
        if (callback != null) {
          callback(event.toString());
        }
      });
    }
    // try {
    //   CallKeep.instance.onEvent.listen((event) async {
    //     // TODO: Implement other events
    //     if (event == null) return;
    //     switch (event.type) {
    //       case CallKeepEventType.callAccept:
    //         await callAccept();
    //         break;
    //       case CallKeepEventType.callDecline:
    //         await callDecline();
    //         break;
    //       case CallKeepEventType.callEnded:
    //         await callDecline();
    //         break;
    //       case CallKeepEventType.callTimedOut:
    //         await callDecline();
    //         break;
    //       default:
    //         break;
    //     }
    //   });
    // }
    on Exception {}
  }

  onEvent(event) {
    if (kDebugMode) {
      print("Event Called: $event");
    }
  }
}