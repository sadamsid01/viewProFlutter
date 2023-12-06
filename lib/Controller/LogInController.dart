// ignore_for_file: file_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:view_pro/Utilities/SecureStorage.dart';
import 'package:view_pro/Utilities/SocketConstants.dart';
import '../Model/UserDataModel.dart';
import 'package:http/http.dart' as http;
import '../Utilities/AppConstants.dart';

class LogInController extends GetxController {
  RxBool isPasswordHidden = true.obs;
  final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var email = "";
  var password = "";
  var isDataLoading = false.obs;
  UserDataModel? agentData;

  @override
  void onInit() async {
    if (kDebugMode) {
      print("LogIn Controller Called");
    }
    emailController.text = '';
    passwordController.text = '';
    super.onInit();
  }

  String? emailValidator(String userEmail) {
    if (!GetUtils.isEmail(userEmail)) {
      return "Email is Incorrect";
    }
    return null;
  }

  String? passwordValidator(String userPassword) {
    if (!GetUtils.isLengthGreaterOrEqual(userPassword, 4)) {
      return "Password Length Should be more than 4";
    }
    return null;
  }

  Future<String?> onLogin() async {
    final isValid = logInFormKey.currentState!.validate();
    if (!isValid)
    {
      return "Failed";
    } else
    {
      logInFormKey.currentState!.save();
      if (kDebugMode)
      {
        print("Email $email");
        print("Password $password");
        return logIn(email,password);
      }
    }
    return null;
  }

  Future<String?> logIn(String userEmail,String userPassword) async{
    try {
      isDataLoading(true);
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (kDebugMode) {
            print('Connected');
          }
          var body = jsonEncode({ 'email': userEmail,'password':userPassword });
          http.Response response = await http.post(
              Uri.parse("${AppConstants.appURL}/agentLogin"),
              headers: {"Content-Type": "application/json"},
              body: body
          );
          if (kDebugMode) {
            print('Status Code: ${response.statusCode}');
          }
          if(response.statusCode == 200) {
            var result = jsonDecode(response.body);
            if (kDebugMode) {
              print("StatusCode: ${response.statusCode}");
              print("Result: $result");
            }
            agentData = UserDataModel.fromJson(result);
            await MyStorage.setDataOfUser(UserDataModel.fromJson(result));
            await MyStorage.setAccessToken(agentData!.agentAccessToken!);
            await MyStorage.setAgentId(agentData!.agentId!);
            await MyStorage.setCallStatus("OnActive");
            agentData = await MyStorage.getDataOfUser();

              if (kDebugMode) {
                print("Agent Access Token: ${agentData!.agentAccessToken!}");
                print("Agent Name: ${agentData!.agentName!}");
                print("Agent ID: ${agentData!.agentId!}");
                print("Agent Image: ${agentData!.agentImage!}");
                print("Agent Avatar: ${agentData!.agentAvatar!}");
                print("Call Status: OnActive");
              }

            var checkForInitSocketStatus = await SocketConstants.initSocket();
            if(checkForInitSocketStatus){
              if (kDebugMode) {
                print("checkForInitSocketStatus at Login: $checkForInitSocketStatus");
              }
              SocketConstants.socket!.connect();
              SocketConstants.socket!.onConnect((_) {
                if (kDebugMode) {
                  print('Socket is ReConnected at Login');
                }
              });
            }
            return "Successful";
          }
          else {
            var result = jsonDecode(response.body);
            if (kDebugMode) {
              print("StatusCode: ${response.statusCode}");
              print("Result: $result");
            }
            return "Failed";
          }
        }
      }
    catch(e)
    {
      if (kDebugMode) {
        print ("Error: $e");
      }
    }
    finally
    {
      isDataLoading(false);
      Restart.restartApp();
    }
    return null;
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print("onClose");
    }
    super.onClose();
  }
}