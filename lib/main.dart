// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'Model/UserDataModel.dart';
import 'Utilities/SecureStorage.dart';
import 'Model/DataForCallModel.dart';
import 'Utilities/AppStateObserver.dart';
import 'Bindings/AppBindings.dart';
import 'Utilities/AppConstants.dart';
import 'Utilities/AppRoutes.dart';
//Background Service
import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Utilities/SocketConstants.dart';

//Initialize Service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Initialize the notification plugin
  await FlutterLocalNotificationsPlugin().initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'View Pro', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'View Pro',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// //Call Parameters
const params = CallKitParams(
  id: "viewProAgent0",
  nameCaller: 'Incoming Call from View Pro',
  appName: 'View Pro',
  avatar: 'https://cdn-icons-png.flaticon.com/512/168/168882.png',
  handle: '',
  type: 0,
  textAccept: 'Accept',
  textDecline: 'Decline',
  duration: 30000,
  extra: <String, dynamic>{'userId': '1a2b3c4d'},
  headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
  android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      backgroundUrl: 'https://wallpapercave.com/wp/wp2801544.jpg',
      actionColor: '#4CAF50',
    ),
    ios: IOSParams(
      iconName: 'ViewPro',
      handleType: 'generic',
      supportsVideo: true,
      maximumCallGroups: 1,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
);

// final callKeepBaseConfig = CallKeepBaseConfig(
//   appName: 'View Pro',
//   androidConfig: CallKeepAndroidConfig(
//     logo: 'logo',
//     notificationIcon: 'notification_icon',
//     ringtoneFileName: 'ringtone.mp3',
//     accentColor: '#34C7C2',
//   ),
//   iosConfig: CallKeepIosConfig(
//     iconName: 'Icon',
//     maximumCallGroups: 1,
//   ),
// );

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  try { //add code execution
    if (kDebugMode) {
      print("Background Service Started");
    }
    var checkForInitSocketStatus = await SocketConstants.initSocket();
    if (checkForInitSocketStatus) {
      if (kDebugMode) {
        print('Socket is Properly Initialised');
      }
      SocketConstants.socket!.connect();
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        SocketConstants.socket!.onConnect((_) {
          if (kDebugMode) {
            print('Socket Connected');
          }
        });
      });
    }
    else {
      if (kDebugMode) {
        print('Socket is not Properly Initialised');
      }
    }
  } catch (err) {
    if (kDebugMode) {
      print(err.toString());
    }
    throw Exception(err);
  }
    //This is triggered once a agent picks a call to make sure it stop ringing on rest of agents
    SocketConstants.socket!.on("callPicked", (data) async {
      UserDataModel? myUserData = await MyStorage.getDataOfUser();
      if (kDebugMode) {
        print("Agent ID (Who Picked Up the Call): ${data['agentId']}");
        print("Agent ID (Who is Logged In): ${myUserData!.agentId}");
      }
      if(data['agentId'] != myUserData!.agentId){
        FlutterCallkitIncoming.endAllCalls();
        // await CallKeep.instance.endAllCalls();
        await MyStorage.setCallStatus("OnActive");
        if (kDebugMode) {
          print("Setting Call Status: OnActive, due to another Agent Picked the Call");
        }
      }
      else {
        if (kDebugMode) {
          print("I Picked Up the Call");
        }
      }
    });

    SocketConstants.socket!.on("NewCallRequest", (data) async {
    if (kDebugMode) {
      print('Call Request Received');
      print("Payload: $data");
    }
    var checkForAccessToken = await MyStorage.checkForAccessToken();

    var checkForCallStatus = await MyStorage.checkForCallStatus();

    if (kDebugMode) {
      print("CheckForAccessToken: $checkForAccessToken");
      print("CheckForCallStatus: $checkForCallStatus");
    }

    if (checkForAccessToken == true && checkForCallStatus == true) {
      if (kDebugMode) {
        print("Agent is Active & Logged In");
      }

      await MyStorage.setDataForCall(DataForCall.fromJson(data));
      await MyStorage.setCallStatus("OnPending");
      await MyStorage.setCallType("New");

      DataForCall? myDataForCall = await MyStorage.getDataForCall();

      bool? callStatus = await MyStorage.checkForCallStatus();

      bool? callType = await MyStorage.checkForCallType();

      if (kDebugMode) {
        print("Call UserSid: ${myDataForCall!.userSid}");
        print("Call AppId: ${myDataForCall.appId}");
        print("Call AppCertificate: ${myDataForCall.appCertificate}");
        print("Call ChannelName: ${myDataForCall.channelName}");
        print("Call Status Pending: $callStatus");
        print("Call Type New: $callType");
      }

      /*
      bool check = await FlutterCallkitIncoming.requestNotificationPermission({
        "rationaleMessagePermission": "Notification permission is required, to show notification.",
        "postNotificationMessageRequired": "Notification permission is required, Please allow notification permission from setting."
      });*/
      bool check = true;
      if(check == true){
        await FlutterCallkitIncoming.showCallkitIncoming(params);
      }
      // Config and uuid are the only required parameters
    //   final config = CallKeepIncomingConfig.fromBaseConfig(
    //     config: callKeepBaseConfig,
    //     uuid: "viewProAgent0",
    //     contentTitle: 'Incoming call from View Pro',
    //     hasVideo: false,
    //     handle: "handle",
    //     callerName: "View Pro"
    //   );
    //   await CallKeep.instance.displayIncomingCall(config);
    }
    else if (checkForAccessToken! == true && checkForCallStatus! == false) {
      if (kDebugMode) {
        print("Agent is either onPending, onCall, or OnOffline & Logged In");
      }
    }
    else if (checkForAccessToken== false && checkForCallStatus! == false) {
      if (kDebugMode) {
        print("Agent is Logged Out, regardless of the Call Status");
      }
    }
  });

    SocketConstants.socket!.on("CallTransfer", (data) async {
    await MyStorage.setDataForCall(DataForCall.fromJson(data));
    String? myAgentId = await MyStorage.getAgentId();
    DataForCall? myDataForTransferCall = await MyStorage.getDataForCall();
    if (kDebugMode) {
      print('Call Request Received');
      print("Payload: $data");
      print("Agent Id from Cache: $myAgentId");
      print("Agent Id from Socket: ${myDataForTransferCall!.agentId}");
    }
    if (myDataForTransferCall!.agentId == myAgentId) {
      var checkForAccessToken = await MyStorage.checkForAccessToken();

      var checkForCallStatus = await MyStorage.checkForCallStatus();

      if (kDebugMode) {
        print("CheckForAccessToken: $checkForAccessToken");
        print("CheckForCallStatus: $checkForCallStatus");
      }
      if (checkForAccessToken == true && checkForCallStatus == true) {
        if (kDebugMode) {
          print("Agent is Active & Logged In");
        }

        await MyStorage.setCallStatus("OnPending");
        await MyStorage.setCallType("Transfer");

        bool? callStatus = await MyStorage.checkForCallStatus();
        bool? callType = await MyStorage.checkForCallType();

        if (kDebugMode) {
          print("Call UserSid: ${myDataForTransferCall.userSid}");
          print("Call AppId: ${myDataForTransferCall.appId}");
          print("Call AppCertificate: ${myDataForTransferCall.appCertificate}");
          print("Call ChannelName: ${myDataForTransferCall.channelName}");
          print("Call Status Pending: $callStatus");
          print("Call Type Transfer: $callType");
        }
        bool check = await FlutterCallkitIncoming.requestNotificationPermission({
          "rationaleMessagePermission": "Notification permission is required, to show notification.",
          "postNotificationMessageRequired": "Notification permission is required, Please allow notification permission from setting."
        });
        if(check == true){
          await FlutterCallkitIncoming.showCallkitIncoming(params);
        }
        // final config = CallKeepIncomingConfig.fromBaseConfig(
        //     config: callKeepBaseConfig,
        //     uuid: "viewProAgent0",
        //     contentTitle: 'Incoming call from View Pro',
        //     hasVideo: false,
        //     handle: "handle",
        //     callerName: "View Pro"
        // );
        // await CallKeep.instance.displayIncomingCall(config);
      }
      else if (checkForAccessToken! == true && checkForCallStatus! == false) {
        if (kDebugMode) {
          print("Agent is either onPending, onCall, or OnOffline & Logged In");
        }
      }
      else if (checkForAccessToken== false && checkForCallStatus! == false) {
        if (kDebugMode) {
          print("Agent is Logged Out, regardless of the Call Status");
        }
      }
    }
    else {
      if (kDebugMode) {
        print('This Call is not for this Agent!');
      }
    }
  });
  // bring to foreground
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'View Pro',
          'You are currently LIVE.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'View Pro',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }

    SocketConstants.socket!.emit("getLiveAgents");
    var checkForAccessToken = await MyStorage.checkForAccessToken();
    if(checkForAccessToken == true){
      //SocketConnectionCheck
      if (SocketConstants.socket!.connected) {
        if (kDebugMode) {
          print('Socket is Connected at the Moment');
        }
      }
      else if (SocketConstants.socket!.disconnected) {
        if (kDebugMode) {
          print('Socket is Not Connected at the Moment');
        }
        SocketConstants.socket!.connect();
        Future.delayed(const Duration(seconds: 5), () {
          //SocketConnectionCheck
          if (SocketConstants.socket!.connected) {
            if (kDebugMode) {
              print('Socket Got Connected');
            }
          }
          else if (SocketConstants.socket!.disconnected) {
            if (kDebugMode) {
              print('Socket is still Not Connected');
            }
          }
        });
      }
    }
    else {
      if (kDebugMode) {
        print("No Access Token Available");
      }
      SocketConstants.socket!.disconnect();
    }
  });
}

Future<void> main() async {
  // Create an instance of the observer
  var observer = AppStateObserver();
  var binding = WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  Timer.run(() {
    binding.attachRootWidget(
      binding.wrapWithDefaultView(MyApp()),
    );
    binding.addObserver(observer);
  });
  binding.scheduleWarmUpFrame();
  await initializeService();
  SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      key: navigatorKey,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      defaultTransition: Transition.leftToRightWithFade,
      title: AppConstants.appTitle,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        backgroundColor: AppConstants.themeBackgroundColor,
        primaryColor: AppConstants.themeMainColor,
        primaryColorDark: AppConstants.themeMainColor,
      ),
      initialBinding: AppBindings(),
      initialRoute: AppConstants.appInitialRoute,
      getPages: appRoutes(),
    );
  }
}