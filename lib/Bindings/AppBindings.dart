// ignore_for_file: file_names

import 'package:get/get.dart';
import '../Controller/BottomNavigationBarController.dart';
import '../Controller/HomeController.dart';
import '../Controller/LogInController.dart';
import '../Controller/SplashController.dart';
import '../Controller/SettingController.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
    Get.lazyPut<BottomNavigationBarController>(() => BottomNavigationBarController());
    Get.lazyPut<LogInController>(() => LogInController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SettingController>(() => SettingController());
  }
}