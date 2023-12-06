// ignore_for_file: must_be_immutable, file_names, unrelated_type_equality_checks

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clipboard/clipboard.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:view_pro/Utilities/SecureStorage.dart';
import '../Model/DataForCallModel.dart';
import '../Model/RemoteParticipantModel.dart';
import '../Model/TokenDataModel.dart';
import '../Model/UserDataModel.dart';
import '../Utilities/AppConstants.dart';
import '../Utilities/SocketConstants.dart';
import '../Model/AgentDataModel.dart';
import '../Model/MessagesModel.dart';
import '../Model/DialogFlowDataModel.dart';
import '../Widgets/Custom Exit Widget.dart';
import '../Widgets/remote_video_views_widget.dart';

class CallView extends StatefulWidget {
  DataForCall? myDataForCall;

  TokenDataModel? myTokenData;

  UserDataModel? myUserData;

  CallView({Key? key, required this.myDataForCall,
    required this.myUserData,required this.myTokenData} ) : super(key: key);

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> with KeepRemoteVideoViewsMixin {
  late final RtcEngineEx _engine;

  bool isPressedForTransfer = false;

  bool isPressedForDialog = false;

  bool isScreenShare = false;

  List<RemoteParticipant> remoteParticipantsUid = [];

  int? clientUid = 0;

  List<MyMessages> messagesList = [];

  List<AgentDataModel> agentsListData = [];

  List<AgentDataModel> activeAgentsListData = [];

  MessagesHistory? messagesHistoryList = MessagesHistory();

  QueryData queryData = QueryData();

  RxList<String> audioSuggestionsList = RxList<String>([]);
  RxList<String> audioSuggestionsResultList = RxList<String>([]);

  TextEditingController searchController = TextEditingController();
  RxList<String> textSuggestionsList = RxList<String>([]);
  RxBool queryLoader = false.obs;

  bool callLeftBy = false;
  bool isJoined = false;
  bool _isLocalParticipantPreviewReady = false;
  bool _isRemoteParticipantPreviewReady = false;

  TextEditingController messageInputTextController = TextEditingController();

  RxBool toggleScreenShareButton = false.obs;
  RxBool toggleVideoButton = true.obs;
  RxBool toggleAudioButton = true.obs;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPluginForSuggestion =
  FlutterLocalNotificationsPlugin();

  var platformChannelSpecifics = const NotificationDetails(
      android: AndroidNotificationDetails(
          'my_foreground',
          'MY FOREGROUND SERVICE',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high)
  );

  int id = 0;

  _CallViewState();

  @override
  void initState() {
    super.initState();
    checkForPreviousCall();
    getMyMessageHistory();
    try {
      _initEngine();
    } catch(e)
    {
      if (kDebugMode) {
        print("InitEngine Error: $e");
      }
    }
    _requestListOfAgents();
    initSocket();
  }

  checkForPreviousCall() async {
    var checkForPreviousCallStatus = await MyStorage.checkForPreviousCallStatus();
    if (kDebugMode) {
      print("CheckForPreviousCallStatus: $checkForPreviousCallStatus");
    }
    if(checkForPreviousCallStatus == true){
      if (kDebugMode) {
        print("Previous Call Found");
      }
      toggleAudioButton.value = (await MyStorage.getBool("ToggleAudioButton"))!;
      toggleVideoButton.value = (await MyStorage.getBool("ToggleVideoButton"))!;
      toggleScreenShareButton.value = (await MyStorage.getBool("ToggleScreenShareButton"))!;
      if (kDebugMode) {
        print("ToggleScreenShareButton: ${toggleScreenShareButton.value}");
        print("ToggleVideoButton: ${toggleVideoButton.value}");
        print("ToggleAudioButton: ${toggleAudioButton.value}");
      }
    }
    else {
      if (kDebugMode) {
        print("No Previous Call Found");
      }
      toggleAudioButton.value = true;
      toggleVideoButton.value = true;
      toggleScreenShareButton.value = false;
      await MyStorage.setBool("ToggleAudioButton", toggleAudioButton.value);
      await MyStorage.setBool("ToggleVideoButton", toggleVideoButton.value);
      await MyStorage.setBool("ToggleScreenShareButton", toggleScreenShareButton.value);
    }
  }

  getMyMessageHistory() async {
    messagesHistoryList = await MyStorage.getMessagesHistoryData();
    if (kDebugMode) {
      print("MessagesList: $messagesHistoryList");
    }
    messagesHistoryList?.data?.forEach((element) {
      if (element.message != null &&
          element.userId != null &&
          element.messageTime != null) {
        messagesList.add(
          MyMessages(
            message: element.message!,
            author: element.userId!.contains(widget.myDataForCall!.userSid!) ? "User" : "Agent",
            timestamp: element.messageTime!,
          ),
        );
      }
    });
  }

  _initEngine() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngineEx();

    await _engine.initialize(RtcEngineContext(
      appId: widget.myDataForCall!.appId,
      logConfig: const LogConfig(level: LogLevel.logLevelError),
      // channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.setDefaultMuteAllRemoteAudioStreams(false);
    _engine.setDefaultMuteAllRemoteVideoStreams(false);

    await _engine.enableVideo();

    _engine.registerEventHandler(RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        if (kDebugMode) {
          print('[onError] err: $err, msg: $msg');
        }
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        if (kDebugMode) {
          print(
              '[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed');
          print('ChannelID: ${connection.channelId}');
        }

        setState(() {
          isJoined = true;
        });
      },
      onUserJoined:  (RtcConnection connection, int remoteUid, int elapsed) {
        final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
        final localUid = int.tryParse(widget.myTokenData!.agentVideoCallUid!);
        if (kDebugMode) {
          print("Remote user uid:$remoteUid joined the channel");
        }
        if (connection.channelId == widget.myDataForCall!.channelName) {
          if(remoteUid != shareShareUid && remoteUid != localUid){
            setState(() {
              if(remoteParticipantsUid.isEmpty){
                if(widget.myDataForCall!.clientUid == 0){
                  clientUid = remoteUid;
                }
                else if(widget.myDataForCall!.clientUid != 0){
                  clientUid = widget.myDataForCall!.clientUid;
                }
                if (kDebugMode) {
                  print("ClientUid $clientUid");
                }
              }
              bool contains = remoteParticipantsUid.any((participant) =>
              participant.uid == remoteUid &&
                  (participant.isVideoMuted == false || participant.isVideoMuted == true ) &&
                  (participant.isAudioMuted == false || participant.isAudioMuted == true ));
              if (!contains) {
                remoteParticipantsUid.add(RemoteParticipant(uid: remoteUid));
              }
              if (kDebugMode) {
                print("RemoteParticipantsUid: $remoteParticipantsUid");
              }
            });
          }
        }
        else if (connection.channelId == widget.myDataForCall!.channelName) {
          if(remoteUid != shareShareUid && remoteUid != localUid){
            setState(() {
              if(remoteParticipantsUid.isEmpty){
                if(widget.myDataForCall!.clientUid == 0){
                  clientUid = remoteUid;
                }
                else if(widget.myDataForCall!.clientUid != 0){
                  clientUid = widget.myDataForCall!.clientUid;
                }
                if (kDebugMode) {
                  print("ClientUid $clientUid");
                }
              }
              bool contains = remoteParticipantsUid.any((participant) =>
              participant.uid == remoteUid &&
                  (participant.isVideoMuted == false || participant.isVideoMuted == true ) &&
                  (participant.isAudioMuted == false || participant.isAudioMuted == true ));
              if (!contains) {
                remoteParticipantsUid.add(RemoteParticipant(uid: remoteUid));
              }
              if (kDebugMode) {
                print("RemoteParticipantsUid: $remoteParticipantsUid");
              }
            });
          }
        }
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType userOfflineReasonType) {
        if (kDebugMode) {
          print("Remote user uid:$remoteUid Left the channel");
        }
        if (connection.channelId == widget.myDataForCall!.channelName) {
          setState(() {
            bool contains = remoteParticipantsUid.any((participant) =>
            participant.uid == remoteUid &&
                (participant.isVideoMuted == false || participant.isVideoMuted == true ) &&
                (participant.isAudioMuted == false || participant.isAudioMuted == true ));

            if (contains) {
              remoteParticipantsUid.removeWhere((element) => element.uid == remoteUid);
              if(clientUid == remoteUid){
                if (kDebugMode) {
                  print("Client has left the Call");
                }
                clientUid = 0;
                callLeftBy = true;
                _leaveChannel();
                _leaveChannelEx();
                _leaveCallSteps();
              }
              else if(clientUid != remoteUid){
                _secondAgentLeaveStep();
              }
            }
            if (kDebugMode) {
              print("Left RemoteParticipantsUid: $remoteParticipantsUid");
            }
          });
        } else if (connection.channelId == widget.myDataForCall!.channelName) {
          setState(() {
            bool contains = remoteParticipantsUid.any((participant) =>
            participant.uid == remoteUid &&
                (participant.isVideoMuted == false || participant.isVideoMuted == true ) &&
                (participant.isAudioMuted == false || participant.isAudioMuted == true ));

            if (contains) {
              remoteParticipantsUid.removeWhere((element) => element.uid == remoteUid);
              if(clientUid == remoteUid){
                if (kDebugMode) {
                  print("Client has left the Call");
                  print("Client has left the Call due to wrong UID store of client ");
                }
                clientUid = 0;
                callLeftBy = true;
                _leaveChannel();
                _leaveChannelEx();
                _leaveCallSteps();
              }
              else if(clientUid != remoteUid){
                _secondAgentLeaveStep();
              }

            }
            if (kDebugMode) {
              print("Left RemoteParticipantsUid: $remoteParticipantsUid");
            }
          });
        }
      },
      onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
        final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
        final localUid = int.tryParse(widget.myTokenData!.agentVideoCallUid!);
        if (kDebugMode) {
          print('User $uid has muted video: $muted');
        }
        if (connection.channelId == widget.myDataForCall!.channelName) {
          if(uid != shareShareUid && uid != localUid){
            setState(() {
              final int index = remoteParticipantsUid.indexWhere((element) => element.uid == uid);
              if (kDebugMode) {
                print("User Found at Index: $index");
              }
              final RemoteParticipant participant = remoteParticipantsUid[index];
              participant.isVideoMuted = muted;
              remoteParticipantsUid[index].isVideoMuted = participant.isVideoMuted;
              _engine.muteRemoteVideoStream(uid: participant.uid, mute: participant.isVideoMuted);
            });
            setState(() {});
          }
        } else if (connection.channelId == widget.myDataForCall!.channelName) {
          if(uid != shareShareUid && uid != localUid){
            setState(() {
              final int index = remoteParticipantsUid.indexWhere((element) => element.uid == uid);
              if (kDebugMode) {
                print("User Found at Index: $index");
              }
              final RemoteParticipant participant = remoteParticipantsUid[index];
              participant.isVideoMuted = muted;
              remoteParticipantsUid[index].isVideoMuted = participant.isVideoMuted;
              _engine.muteRemoteVideoStream(uid: participant.uid, mute: participant.isVideoMuted);
            });
            setState(() {});
          }
        }
      },
      onUserMuteAudio: (RtcConnection connection, int uid, bool muted) {
        final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
        final localUid = int.tryParse(widget.myTokenData!.agentVideoCallUid!);
        if (kDebugMode) {
          print('User $uid has muted audio: $muted');
        }
        if (connection.channelId == widget.myDataForCall!.channelName) {
          if(uid != shareShareUid && uid != localUid){
            setState(() {
              final int index = remoteParticipantsUid.indexWhere((element) => element.uid == uid);
              if (kDebugMode) {
                print("User Found at Index: $index");
              }
              final RemoteParticipant participant = remoteParticipantsUid[index];
              participant.isAudioMuted = muted;
              remoteParticipantsUid[index].isAudioMuted = participant.isAudioMuted;
              _engine.muteRemoteAudioStream(uid: participant.uid, mute: participant.isAudioMuted);
            });
            setState(() {});
          }
        } else if (connection.channelId == widget.myDataForCall!.channelName) {
          if(uid != shareShareUid && uid != localUid){
            setState(() {
              final int index = remoteParticipantsUid.indexWhere((element) => element.uid == uid);
              if (kDebugMode) {
                print("User Found at Index: $index");
              }
              final RemoteParticipant participant = remoteParticipantsUid[index];
              participant.isAudioMuted = muted;
              remoteParticipantsUid[index].isAudioMuted = participant.isAudioMuted;
              _engine.muteRemoteAudioStream(uid: participant.uid, mute: participant.isAudioMuted);
            });
            setState(() {});
          }
        }
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        _leaveChannel();
        _leaveChannelEx();
        if (kDebugMode) {
          print(
              '[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
        }
        setState(() {
          isJoined = false;
        });
      },
      onLocalVideoStateChanged: (VideoSourceType source,LocalVideoStreamState state, LocalVideoStreamError error) {
        if (kDebugMode) {
          print(
              '[onLocalVideoStateChanged] source: $source, state: $state, error: $error');
        }
        if (!(source == VideoSourceType.videoSourceScreen ||
            source == VideoSourceType.videoSourceScreenPrimary)) {
          return;
        }

        switch (state) {
          case LocalVideoStreamState.localVideoStreamStateCapturing:
            setState(() {
              toggleScreenShareButton.value = true;
            });
            break;
          case LocalVideoStreamState.localVideoStreamStateEncoding:
            setState(() {
              toggleScreenShareButton.value = true;
            });
            break;
          case LocalVideoStreamState.localVideoStreamStateStopped:
            setState(() {
              toggleScreenShareButton.value = false;
            });
            break;
          case LocalVideoStreamState.localVideoStreamStateFailed:
            setState(() {
              toggleScreenShareButton.value = false;
            });
            break;
          default:
            break;
        }
      },
    ));

    _joinChannel();

    await _engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 1920, height: 1080),
        frameRate: 15,
        bitrate: 0,
      ),
    );
    setState(() {
      _isLocalParticipantPreviewReady = true;
      _isRemoteParticipantPreviewReady = true;
    });
    if (kDebugMode) {
      print("IsLocalParticipantPreviewReady: $_isLocalParticipantPreviewReady");
      print("IsRemoteParticipantPreviewReady: $_isRemoteParticipantPreviewReady");
    }
  }

  void _joinChannel() async {
    await _engine.startPreview();
    final localUid = int.tryParse(widget.myTokenData!.agentVideoCallUid!);
    if (kDebugMode) {
      print("AgentUid: $localUid");
    }
    if (localUid != null) {
      await _engine.joinChannel(
        token: widget.myTokenData!.agentVideoRoomAccessToken!,
        channelId: widget.myDataForCall!.channelName!,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
        uid: localUid,
      );
    }
    setState(() {
      toggleVideoButton.value = true;
      toggleAudioButton.value = true;
      //_engine.enableLocalVideo(toggleVideoButton.value);
    });
  }

  void _joinChannelEx() async {
    final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
    await _engine.joinChannelEx(
        token: widget.myTokenData!.agentScreenShareAccessToken!,
        connection: RtcConnection(
            channelId: widget.myDataForCall!.channelName!, localUid: shareShareUid),
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: false,//true
          publishScreenTrack: false,
          publishScreenCaptureAudio: false,//true
          publishScreenCaptureVideo: false,
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
          publishSecondaryScreenTrack: false
        ));
  }

  _leaveChannel() async {
    LeaveChannelOptions leaveChannelOptions = const LeaveChannelOptions(
        stopAllEffect: true
    );
    await _engine.leaveChannel(options: leaveChannelOptions);
  }

  _leaveChannelEx() async {
    final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
    RtcConnection connection =RtcConnection(
        channelId: widget.myDataForCall!.channelName, localUid: shareShareUid);
    LeaveChannelOptions leaveChannelOptions = const LeaveChannelOptions(
        stopAllEffect: false
    );
    await _engine.leaveChannelEx(connection: connection, options: leaveChannelOptions);
  }

  _leaveCallSteps() async {
    if(isScreenShare == true){
      screenShareOff(false);
    }

    await MyStorage.setPreviousCallStatus("No");
    await MyStorage.setCallStatus("OnActive");
    await MyStorage.clearDataForToken();
    await MyStorage.removeString("myDataForCall");
    var checkForPreviousCallStatus = await MyStorage.checkForPreviousCallStatus();
    if (kDebugMode) {
      print("Call Status: OnActive");
      print("CheckForPreviousCallStatus: $checkForPreviousCallStatus");
    }
    //Code Added
    var myData = jsonEncode({
      'userSid': widget.myDataForCall!.userSid,
      'uid': widget.myTokenData!.agentVideoCallUid!,
      //Code Added
      'screenShareUid': widget.myTokenData!.agentScreenShareUid!
    });
    SocketConstants.socket!.emit('agentLeaveConversation', myData);
    Get.toNamed("/bnb");
    await Fluttertoast.showToast(
        msg: (callLeftBy)?"Client has left the Call":"You have left the Call",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: AppConstants.themeMainColor,
        textColor: AppConstants.themeBackgroundColor,
        fontSize: 16.0
    );
  }

  _secondAgentLeaveStep() async {
    await MyStorage.setPreviousCallStatus("No");
    var checkForPreviousCallStatus = await MyStorage.checkForPreviousCallStatus();
    if (kDebugMode) {
      print("CheckForPreviousCallStatus: $checkForPreviousCallStatus");
    }
    await Fluttertoast.showToast(
        msg: "Other Agent have left the Call",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: AppConstants.themeMainColor,
        textColor: AppConstants.themeBackgroundColor,
        fontSize: 16.0
    );
  }

  Future<void> _updateScreenShareChannelMediaOptions() async {
    final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
    if (shareShareUid == null) return;
    await _engine.updateChannelMediaOptionsEx(
      options: const ChannelMediaOptions(
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenTrack: false,
          publishScreenCaptureAudio: false,
          publishScreenCaptureVideo: true,
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
          publishSecondaryScreenTrack: false
      ),
      connection:
      RtcConnection(channelId: widget.myDataForCall!.channelName!, localUid: shareShareUid),
    );
  }

  screenShareOn() async {
    final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
    //Code Added
    final videoUid = int.tryParse(widget.myTokenData!.agentVideoCallUid!);
    setState(() {
      if (kDebugMode) {
        print("Before ToggleVideoButton: $toggleVideoButton");
      }
      toggleVideoButton.value=!toggleVideoButton.value;
      if (kDebugMode) {
        print("After ToggleVideoButton: $toggleVideoButton");
      }
      //_engine.enableLocalVideo(toggleVideoButton.value);
    });
    await MyStorage.setBool("ToggleVideoButton", toggleVideoButton.value);
    var body = jsonEncode({
      'userSid': widget.myDataForCall!.userSid!,
      'uid': shareShareUid.toString(),
      //Code Added
      'videoUid': videoUid.toString()
    });
    SocketConstants.socket!.emit('startScreenShare',body);
    Timer(const Duration(seconds: 3), () async {
      //SocketConstants.socket!.emit('startScreenShare',body);
      _joinChannelEx();
      // _leaveChannel();
      await _engine.startScreenCapture(
          const ScreenCaptureParameters2(captureAudio: false, captureVideo: true));
      await _engine.startPreview(sourceType: VideoSourceType.videoSourceScreen);
      _updateScreenShareChannelMediaOptions();
      if (kDebugMode) {

        print("Yeah, this line is printed after 3 seconds");
      }
    });
  }

  screenShareOff(bool byButton) async {
    // if(toggleScreenShareButton.value == false){
      final shareShareUid = int.tryParse(widget.myTokenData!.agentScreenShareUid!);
      //Code Added
      final videoUid = int.tryParse(widget.myTokenData!.agentVideoCallUid!);
      await MyStorage.setBool("ToggleVideoButton", toggleVideoButton.value);
      var body = jsonEncode({
        'userSid': widget.myDataForCall!.userSid,
        'uid': shareShareUid.toString(),
        //Code Added
        'videoUid': videoUid.toString()
      });
      await _engine.stopScreenCapture();
      if(byButton == true){
        setState(() {
          //_updateVideoCallChannelMediaOptions();
        });
      }
      setState(() {
        if (kDebugMode) {
          print("Before ToggleVideoButton: $toggleVideoButton");
        }
        toggleVideoButton.value = true;
        if (kDebugMode) {
          print("After ToggleVideoButton: $toggleVideoButton");
          print("After ToggleVideoButton: $toggleVideoButton");
        }
        // _engine.enableLocalVideo(toggleVideoButton.value);
      });

      SocketConstants.socket!.emit('stopScreenShare',body);
    }
  // }

  initSocket() async {
    var checkForInitSocketStatus = await SocketConstants.initSocket();
    if(checkForInitSocketStatus){
      if (kDebugMode) {
        print("checkForInitSocketStatus at Call View: $checkForInitSocketStatus");
      }
      SocketConstants.socket!.connect();
      SocketConstants.socket!.onConnect((_) {
        if (kDebugMode) {
          print('Socket is ReConnected at Call View');
        }
      });
      SocketConstants.socket!.on('liveAgentsList', (data) {
        Map<String, dynamic> json = jsonDecode(data.toString());
        List<String> agentList = List<String>.from(json['agentList']);
        if (kDebugMode) {
          print("Live Agents List: $agentList");
        }
        if (kDebugMode) {
          print("All Agents List: $agentsListData");
        }
        setState(() {
          activeAgentsListData = [];
          if(agentsListData.isNotEmpty){
            // activeAgentsListData = agentsListData;
            for (var item1 in agentsListData) {
              if (kDebugMode) {
                print("item1: ${item1.agentId}");
              }
              for (var item2 in agentList) {
                if (kDebugMode) {
                  print("item2: $item2");
                }
                if (item1.agentId == item2) {
                  // Add the copied item to the third list
                  activeAgentsListData.add(item1);
                  break; // Stop comparing once a match is found
                }
              }
            }
          }
          if (kDebugMode) {
            print("ActiveAgentsListData: $activeAgentsListData");
          }
        });
      });
      SocketConstants.socket!.on('userMessage', (message) {
        if (kDebugMode) {
          print("User Data in Message: $message");
        }
        setState(() {
          messagesList.add(MyMessages(message: message['message'],
              author: "User",
              timestamp: message['messageTime']));
        });
      });
      SocketConstants.socket!.on('agentMessage', (message) {
        if (kDebugMode) {
          print("Agent Data in Message: $message");
        }
        setState(() {
          messagesList.add(MyMessages(message: message['message'],
              author: (message['agentName'] == widget.myUserData!.agentName)?
              widget.myUserData!.agentName:message['agentName'],
              timestamp: message['messageTime']));
        });
      });
      SocketConstants.socket!.on('dialougeFlowResponses', (body) {
        if (kDebugMode) {
          print("SpeechText Body: $body");
        }
        audioSuggestionsList.add(body['text']); // Adding the new text to the list of strings
      });
      // Periodic task to check for new texts in the list
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (audioSuggestionsList.isNotEmpty) {
          String latestText = audioSuggestionsList.last; // Get the latest text from the list
          _requestAudioSuggestions(latestText); // Pass the latest text to the function
          audioSuggestionsList.removeLast(); // Remove the latest text from the list
          setState(() {});
        }
      });
    }
  }

  _sendMessage() {
    String messageText = messageInputTextController.text.trim();
    messageInputTextController.clear();
    if (messageText != '') {
      var myData = jsonEncode({
        'agentName': widget.myUserData!.agentName,
        'agentSid': widget.myUserData!.agentId,
        'userSid': widget.myDataForCall!.userSid!,
        'message': messageText,
        'messageTime': DateTime.now().toString(),
      });
      SocketConstants.socket!.emit('agentSendMessage', myData);
    }
  }

  _requestListOfAgents() async {
    agentsListData = [];
    http.Response response = await http.get(
        Uri.parse("${AppConstants.appURL}/getAllAgents"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.myUserData!.agentAccessToken!}'
        }
    );
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print("StatusCode: ${response.statusCode}");
        print("Result: $data");
      }
      List<Map<String, dynamic>> map = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      for (var element in map) {
        agentsListData.add(AgentDataModel.fromJson(element));
      }
      agentsListData.removeWhere((element) => element.agentId ==
          widget.myUserData!.agentId);
      if (kDebugMode) {
        print("AgentsListData: $agentsListData");
      }
    }
    else {
      var result = jsonDecode(response.body);
      if (kDebugMode) {
        print("StatusCode: ${response.statusCode}");
        print("Result: $result");
      }
      Get.snackbar("Request Failed", "Unable to do Fetch Agent");
    }
  }

  Future<void> _showNotification(String? notificationBody) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'my_foreground', // id
      'View Pro',
      channelDescription: 'channel_description',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'View Pro', // Notification title
      notificationBody, // Notification body
      platformDetails,
      payload: notificationBody,
    );
  }

  void copyText(String text) {
    FlutterClipboard.copy(text).then(( value ) {
      if (kDebugMode) {
        print('Value Copied');
      }});
  }

  void copyAudio(String audio) {
    FlutterClipboard.copy(audio).then(( value ) {
      if (kDebugMode) {
        print('Value Copied');
      }});
  }

  _requestAudioSuggestions(String? suggestionText) async {
    var body = jsonEncode({
      'text': suggestionText,
    });
    if (kDebugMode) {
      print("RequestSuggestionText Body: $body");
    }
    http.Response response = await http.post(
        Uri.parse("${AppConstants.appURL}/dialogFlowResponse"),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${widget.myUserData!.agentAccessToken!}"
        },
        body: body
    );
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print("StatusCode: ${response.statusCode}");
        print("Result: ${data['response']}");
      }
      String? notificationBody = data['response'];
      //Call Notification Function
      _showNotification(notificationBody!);
      audioSuggestionsResultList.add(notificationBody);
      setState(() {});
    }
    else {
      var result = jsonDecode(response.body);
      if (kDebugMode) {
        print("StatusCode: ${response.statusCode}");
        print("Result: $result");
      }
      Get.snackbar("Search Failed", "Unable to Load the Suggestion");
    }
  }

  searchTextSuggestions(String? query) async {
    setState(() {
      queryLoader.toggle();
    });
    var body = jsonEncode({
      'queryText': query,
    });
    if (kDebugMode) {
      print("Body: $body");
    }
    http.Response response = await http.post(
        Uri.parse("${AppConstants.appURL}/getDialogeFlowSuggestions"),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${widget.myUserData!.agentAccessToken}"
        },
        body: body
    );
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print("StatusCode: ${response.statusCode}");
        print("Result: $data");
      }
      queryData = QueryData.fromJson(data);
      final searchedQuery = queryData.dialogFlow?.first;
      textSuggestionsList.clear();
      textSuggestionsList.add(searchedQuery!);
      setState(() {});
      if (kDebugMode) {
        print("SearchedQuery: $searchedQuery");
      }
      setState(() {
        queryLoader.toggle();
      });
    }
    else {
      var result = jsonDecode(response.body);
      if (kDebugMode) {
        print("StatusCode: ${response.statusCode}");
        print("Result: $result");
      }
      Get.snackbar("Search Failed", "Unable to Search the Query");
      setState(() {
        queryLoader.toggle();
      });
    }
  }

  Widget _buildTextSuggestionsTab() {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onSubmitted: (value)
          {
            searchController.text = value;
            searchTextSuggestions(value);
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              filled: true,
              fillColor: AppConstants.themeBackgroundColor,
              focusColor: AppConstants.themeMainColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                color: AppConstants.themeMainColor,
                onPressed: () {
                  String value = searchController.text;
                  searchTextSuggestions(value);
                },
              ),
              suffixIconColor: AppConstants.themeMainColor,
              // labelText: 'Email',
              hintText: 'Enter Your Query Here'),
        ),
        Expanded(
            child: Obx(() => ListTile(
              title: Text(textSuggestionsList.isNotEmpty ? textSuggestionsList.first : ''),
              trailing: IconButton(
                icon: const Icon(Icons.content_copy),
                onPressed: () => copyText(textSuggestionsList.isNotEmpty ? textSuggestionsList.first : '',),
              ),
            ))
        ),
      ],
    );
  }

  Widget _buildAudioSuggestionsTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() => ListView.builder(
            itemCount: audioSuggestionsResultList.length,
            itemBuilder: (BuildContext context, int index) {
              final reverseIndex = audioSuggestionsResultList.length - index - 1;
              return ListTile(
                title: Text(audioSuggestionsResultList[reverseIndex]),
                trailing: IconButton(
                  icon: const Icon(Icons.content_copy),
                  onPressed: () => copyAudio(audioSuggestionsResultList[index]),
                ),
              );
            },
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        color: AppConstants.themeMainColor,
        padding: const EdgeInsets.all(10),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget popUpDialogForTextAudioSuggestions(){
    return Dialog(
      child: Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  automaticIndicatorColorAdjustment: false,
                  indicatorColor: AppConstants.themeMainColor, // Set color of selected tab indicator
                  labelColor: Colors.black, // Set text color of selected tab labels
                  unselectedLabelColor: Colors.grey, // Set text color of unselected tab labels
                  tabs: const [
                    Tab(text: 'Text',),
                    Tab(text: 'Audio'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTextSuggestionsTab(),
                      _buildAudioSuggestionsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _buildCloseButton(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SocketConstants.socket!.disconnect();
    super.dispose();
  }

  Widget _remoteVideo(RemoteParticipant currentRemoteParticipantUid) {
    if (currentRemoteParticipantUid.uid != 1) {
      if(currentRemoteParticipantUid.isVideoMuted == true){
        return Container(color: Colors.white24,);
      }
      else if (currentRemoteParticipantUid.isVideoMuted == false){
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: currentRemoteParticipantUid.uid),
            connection: RtcConnection(channelId: widget.myDataForCall!.channelName!),
          ),
        );
      } else{
        return Container(color: Colors.white24,);
      }
    } else {
      String msg = '';
      if (_isRemoteParticipantPreviewReady) msg = 'Waiting for a remote user to join';
      return Center(
        child: Text(
          msg,
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ExitConfirmationDialog(
                title: "Exit Alert",
                content: "Do you wish to End the Call"
            );
          },
        );
        if (shouldExit == true) {
          // User wants to exit the app
          _leaveChannel();
          _leaveChannelEx();
          _leaveCallSteps();

        }
        // Return false to indicate that we don't want to exit the app
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0.0,
          ),
          body: Stack(
            children: [
              SizedBox(
                  width: AppConstants.appWidth,
                  height: AppConstants.appHeight,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          children: [
                            //Remote Participants Videos
                            (remoteParticipantsUid.isNotEmpty)?
                            Container(
                              height: AppConstants.appHeight,
                              width: AppConstants.appWidth,
                              color: Colors.black54,
                              child: ListView.builder(
                                  itemCount: remoteParticipantsUid.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container (
                                      height: (remoteParticipantsUid.length > 1)?
                                      AppConstants.appHeight*.50:
                                      AppConstants.appHeight*.99,
                                      width: AppConstants.appWidth,
                                      decoration: BoxDecoration(
                                        border: (remoteParticipantsUid.length > 1)?
                                        Border.all(
                                            width: 2.0,
                                            color: AppConstants.themeMainColor):
                                        Border.all(
                                            width: 2.0,
                                            color: Colors.green),
                                        color: Colors.black54,
                                      ),
                                      child: _remoteVideo(remoteParticipantsUid[index]),
                                    );
                                  }),
                            ):Container(color: Colors.black54,),
                            //Current Agent Name & Image
                            Positioned(
                              top: 10,
                              left: 15,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                      backgroundImage: NetworkImage(widget.myUserData!.agentAvatar!),
                                      minRadius: AppConstants.appRadius*2.5),
                                  const SizedBox(width: 10,),
                                  Text(widget.myUserData!.agentName!,style: const TextStyle(color: Colors.white),)
                                ],
                              ),
                            ),
                            //Current Agent Video
                            (toggleVideoButton.isTrue)?
                            Positioned(
                              top: 100,
                              left: 15,
                              child: SizedBox(
                                height: 150,
                                width: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  //Add Agora Video Here
                                  child: (_isLocalParticipantPreviewReady)?
                                  AgoraVideoView(
                                    controller: VideoViewController(
                                      rtcEngine: _engine,
                                      canvas: const VideoCanvas(uid: 0),
                                      useFlutterTexture: false,
                                      useAndroidSurfaceView: true,
                                    ),
                                  ):const Center(child: CircularProgressIndicator(),),
                                ),
                              ),
                            ):Container(),
                            //Action Buttons
                            Positioned(
                              top: 10,
                              right: 5,
                              child: Container(
                                color: Colors.black12.withOpacity(.25),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //Hang Up Button
                                    MaterialButton(
                                      onPressed: () async {
                                        _leaveChannel();
                                        _leaveChannelEx();
                                        _leaveCallSteps();
                                      },
                                      child: Image.asset('assets/icons/end_call.png',color: Colors.white,),
                                    ),
                                    //Mic Button
                                    MaterialButton(
                                      onPressed: () async {
                                        setState(() {
                                          if (kDebugMode) {
                                            print("Before ToggleAudioButton: $toggleAudioButton");
                                          }
                                          toggleAudioButton.value=!toggleAudioButton.value;
                                          if (kDebugMode) {
                                            print("After ToggleAudioButton: $toggleAudioButton");
                                          }
                                          _engine.enableLocalAudio(toggleAudioButton.value);
                                        });
                                        await MyStorage.setBool("ToggleAudioButton", toggleAudioButton.value);
                                      },
                                      child: toggleAudioButton.isTrue?
                                      Image.asset('assets/icons/mic_on.png',color: Colors.white,):
                                      Image.asset('assets/icons/mic_off.png',color: Colors.white,),
                                    ),
                                    //Video Button
                                    MaterialButton(
                                      onPressed: () async {
                                        setState(() {
                                          if (kDebugMode) {
                                            print("Before ToggleVideoButton: $toggleVideoButton");
                                          }
                                          toggleVideoButton.value=!toggleVideoButton.value;
                                          if (kDebugMode) {
                                            print("After ToggleVideoButton: $toggleVideoButton");
                                          }
                                          _isLocalParticipantPreviewReady = true;
                                          _engine.enableLocalVideo(toggleVideoButton.value);
                                        });
                                        await MyStorage.setBool("ToggleVideoButton", toggleVideoButton.value);
                                      },
                                      child: toggleVideoButton.isTrue?
                                      Image.asset('assets/icons/video_on.png',color: Colors.white,):
                                      Image.asset('assets/icons/video_off.png',color: Colors.white,),
                                    ),
                                    //Switch Camera Button
                                    MaterialButton(
                                      onPressed: () {
                                        _engine.switchCamera();
                                      },
                                      child: Image.asset('assets/icons/switch_camera.png',color: Colors.white,),
                                    ),
                                    //Screen Share Button
                                    MaterialButton(
                                      onPressed: () async {
                                        setState(() {
                                          if (kDebugMode) {
                                            print("Before ToggleScreenShareButton: $toggleScreenShareButton");
                                          }
                                          toggleScreenShareButton.value=!toggleScreenShareButton.value;
                                          if (kDebugMode) {
                                            print("After ToggleScreenShareButton: $toggleScreenShareButton");
                                          }
                                          if(toggleScreenShareButton.isTrue) {
                                            isScreenShare = true;
                                            screenShareOn();
                                          }
                                          else if(toggleScreenShareButton.isFalse) {
                                            isScreenShare = false;
                                            screenShareOff(true);
                                          }
                                        });
                                        await MyStorage.setBool("ToggleScreenShareButton", toggleScreenShareButton.value);
                                      },
                                      child: Image.asset('assets/icons/switch.png',color: (toggleScreenShareButton.isFalse)?Colors.white:Colors.green,),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: SizedBox(
                    width: AppConstants.appWidth,
                    height: AppConstants.appHeight*.60,
                    child: _buildBody()
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget _buildModalForAgentList() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: AppConstants.themeBackgroundColor,
            width: AppConstants.appWidth,
            height: AppConstants.appHeight * .10,
            child: Padding(
              padding: EdgeInsets.only(left:AppConstants.appRadius,right: AppConstants.appRadius,top: AppConstants.appPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                const [
                  Text("Agent Icon",style: TextStyle(color: Colors.black),),
                  Text("Agent Name",style: TextStyle(color: Colors.black),),
                  Text("Action",style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
          ),
          Container(
            width: AppConstants.appWidth,
            height: AppConstants.appHeight * .80,
            color: AppConstants.themeBackgroundColor,
            child: ListView.builder(
              reverse: false,
              itemCount: activeAgentsListData.length,
              itemBuilder: (_, index) {
                return _buildAgentListItem(activeAgentsListData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentListItem(AgentDataModel agentsListData) {
    return Padding(
      padding: EdgeInsets.all(AppConstants.appRadius),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
        [
          CircleAvatar(
              backgroundImage: NetworkImage(agentsListData.agentImage!),
              minRadius: AppConstants.appRadius*2),
          Text("Agent Name: ${agentsListData.name}",style: const TextStyle(color: Colors.black),),
          IconButton(
            onPressed: () {
              Fluttertoast.showToast(
                  msg: "Agent ${agentsListData.name} has been requested for Call",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 5,
                  backgroundColor: AppConstants.themeMainColor,
                  textColor: AppConstants.themeBackgroundColor,
                  fontSize: 16.0
              );
              var myData = jsonEncode({
                'appId': widget.myDataForCall!.appId,
                'appCertificate': widget.myDataForCall!.appCertificate,
                'channelName': widget.myDataForCall!.channelName!,
                'clientUid': clientUid,
                'userSid': widget.myDataForCall!.userSid,
                'agentId': agentsListData.agentId
              });
              if (kDebugMode) {
                print("Body: $myData");
                print("ClientUid for Transfer: $clientUid");
              }
              SocketConstants.socket!.emit('AgentCallTransfer', myData);
            },
            icon: const Icon(Icons.call,color: Colors.black,),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 10,right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                color: Colors.transparent,
                height: AppConstants.appHeight*.45,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Container(
                        color: Colors.transparent,
                        height: AppConstants.appHeight*.25,
                        child: _buildListStates(),
                      ),
                    ),
                  ],
                )
            ),
            _buildMessageInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildListStates() {
    if (messagesList.isEmpty) {
      return Container(
        color: Colors.transparent,
        height: AppConstants.appHeight*.50,
        child: const Center(
          child: Icon(
            Icons.speaker_notes_off,
            size: 48,
          ),
        ),
      );
    }

    return _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      reverse: false,
      itemCount: messagesList.length,
      itemBuilder: (_, index) {
        return _buildListItem(messagesList[index]);
      },
    );
  }

  Widget _buildListItem(MyMessages message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(color: Colors.transparent,child: _buildChatBubble(message)),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MyMessages message) {
    bool isMyMessage = false;
    if(message.author == widget.myUserData!.agentName!) {
      isMyMessage = true;
    }
    return GestureDetector(
      onLongPressEnd: (LongPressEndDetails details) =>
          _showMessageOptionsMenu(message.message, details.globalPosition),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isMyMessage ?
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: CircleAvatar(
                backgroundImage: NetworkImage(widget.myUserData!.agentAvatar!),
                minRadius: AppConstants.appRadius*2),
          ):
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: CircleAvatar(
                backgroundImage: AssetImage(AppConstants.logoImageURL,),
                minRadius: AppConstants.appRadius*2),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250, minHeight: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAuthorName(
                    author: message.author,
                  ),
                  _buildMessageContents(
                    message: message.message,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorName({
    required String? author,
  }) {
    // TODO: revisit logic, seems wonky
    return Text(
      author!,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMessageContents({
    required String? message,
  }) {
    return Text(
      message ?? '',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 13,
      ),
    );

  }

  Future _showMessageOptionsMenu(String? message, Offset position) async {
    final option = (await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
            position.dx, position.dy, position.dx, position.dy),
        items: [
          const PopupMenuItem(
            value: "Copy",
            child: Text('Copy'),
          )
        ]));

    switch (option) {
      case "Copy":
        _copyMessage(message);
        break;
      default:
        break;
    }
  }

  Future _copyMessage(String? message) async {

    FlutterClipboard.copy(message!).then(( value ) {
      if (kDebugMode) {
        print('Value Copied');
      }});
  }

  Widget _buildMessageInputBar() {
    return Container(
      color: Colors.transparent,
      height: AppConstants.appHeight*.10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: AppConstants.appWidth*.65,
              child: TextFormField(
                  controller: messageInputTextController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter Message Here",
                    hintStyle: const TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                  )
              )),
              SizedBox(
                height: 30,
                width: 30,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: isPressedForTransfer ? Colors.blue.withOpacity(0.8) : Colors.transparent,
                        offset: const Offset(0.0, 3.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        isPressedForTransfer = !isPressedForTransfer;
                      });
                      Future.delayed(const Duration(milliseconds: 2500), () {
                        setState(() {
                          isPressedForTransfer = !isPressedForTransfer;
                        });
                      });
                      showModalBottomSheet<void>(
                        isDismissible: true,
                        elevation: 1.0,
                        context: context,
                        backgroundColor: AppConstants.themeBackgroundColor,
                        builder: (context) => _buildModalForAgentList(),
                      );
                    },
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(
                      'assets/icons/transfer_call.png',
                      color: Colors.white,
                      height: 25,
                      width: 25,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                width: 30,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: isPressedForDialog ? Colors.blue.withOpacity(0.8) : Colors.transparent,
                        offset: const Offset(0.0, 3.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        isPressedForDialog = !isPressedForDialog;
                      });
                      Future.delayed(const Duration(milliseconds: 2500), () {
                        setState(() {
                          isPressedForDialog = !isPressedForDialog;
                        });
                      });
                  showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return popUpDialogForTextAudioSuggestions();
                  },
                );
              },
              padding: const EdgeInsets.all(0),
              child: Image.asset('assets/icons/help.png',color: Colors.white,height: 25,width: 25,),
            ),
          ),),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      child: SizedBox(
        height: 30,
        width: 30,
        child: MaterialButton(
          // onPressed: messagesNotifier.onSendMessagePressed,
          onPressed: _sendMessage,
          padding: const EdgeInsets.all(0),
          child: Image.asset('assets/icons/send.png',color: Colors.white,height: 25,width: 25,),
        ),
      ),
    );
  }
}