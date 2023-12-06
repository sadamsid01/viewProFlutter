// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:view_pro/Utilities/SecureStorage.dart';
import 'package:view_pro/Utilities/SocketConstants.dart';

class SplashController extends GetxController {

  bool? checkForAccessToken = false;

  @override
  void onInit() async {
    if (kDebugMode) {
      print("Splash Controller Called");
    }
    // TODO: implement onInit
    super.onInit();
  }
}