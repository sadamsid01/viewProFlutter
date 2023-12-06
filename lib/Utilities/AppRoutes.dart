import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Model/DataForCallModel.dart';
import '../Model/TokenDataModel.dart';
import '../Model/UserDataModel.dart';
import '../Bindings/AppBindings.dart';
import '../View/BottomNavigationBarView.dart';
import '../View/CallView.dart';
import '../View/LogInView.dart';
import '../View/HomeView.dart';
import '../View/SettingView.dart';
import '../View/SplashView.dart';

appRoutes() => [
  GetPage(
    name: '/splash',
    page: () => const SplashView(),
    binding:AppBindings(),
    transition: Transition.leftToRightWithFade,
    transitionDuration: const Duration(milliseconds: 500)
  ),
  GetPage(
    name: '/bnb',
    page: () => const BottomNavigationBarView(),
    binding:AppBindings(),
    transition: Transition.leftToRightWithFade,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: '/logInSignUp',
    page: () => LogInView(),
    binding:AppBindings(),
    transition: Transition.leftToRightWithFade,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: '/home',
    page: () => HomeView(),
    binding:AppBindings(),
    transition: Transition.leftToRightWithFade,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: '/setting',
    page: () => SettingView(),
    binding:AppBindings(),
    transition: Transition.leftToRightWithFade,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: '/callView',
    binding:AppBindings(),
    page: () => CallView(myTokenData: TokenDataModel(
      agentVideoRoomAccessTokenValue: "", agentScreenShareAccessTokenValue: "",
      agentVideoCallUidValue: "", agentScreenShareUidValue: ""),
      myDataForCall: DataForCall(),myUserData: UserDataModel()),
    transition: Transition.leftToRightWithFade,
    transitionDuration: const Duration(milliseconds: 500),
  )
];