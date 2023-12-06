// ignore_for_file: file_names
import 'package:get/get.dart';
import 'package:view_pro/Utilities/SecureStorage.dart';

class BottomNavigationBarController extends GetxController{
  final notificationsStatus = false.obs;
  final workAvailabilityStatus = false.obs;
  RxBool? loadingData = false.obs;
  var tabIndex = 0;
  @override
  Future<void> onInit() async {
    checkWorkAvailabilityStatus();
    // TODO: implement onInit
    super.onInit();
  }

  void changeTabIndex(int index){
    tabIndex = index;
    update();
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