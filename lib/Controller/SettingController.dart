// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:view_pro/Utilities/SecureStorage.dart';

class SettingController extends GetxController {

  final notificationsStatus = false.obs;
  final workAvailabilityStatus = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    if (kDebugMode) {
      print("SettingController Called");
    }
    checkWorkAvailabilityStatus();
    super.onInit();
  }

  checkWorkAvailabilityStatus() async {
    var checkForCallStatus = await MyStorage.checkForCallStatus();
    if(checkForCallStatus == true) {
      workAvailabilityStatus.value = true;
    }
    else if(checkForCallStatus == false) {
      workAvailabilityStatus.value = false;
    }
    update();
  }
}