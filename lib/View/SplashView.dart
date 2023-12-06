// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utilities/AppConstants.dart';
import '../Controller/SplashController.dart';
import '../Widgets/Custom Splash Screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final SplashController splashController = Get.find();

  @override
  Widget build(BuildContext context) {
    return CustomSplashScreen(
      logo: Image.asset(AppConstants.logoImageURL,color: AppConstants.splashThemeLogoColor),
      logoWidth: MediaQuery.of(context).size.width*.70,
      backgroundColor: AppConstants.splashThemeBackgroundColor,
      durationInSeconds: 5,
    );
  }
}