import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppConstants
{
  static String appTitle = "View Pro";
  static String appEmail = "viewpro@gmail.com";
  static const String appURL = 'https://viewpro.com/api/agentRoutes';
  static TextStyle h1 = TextStyle(color: themeSecondaryColor,
      fontWeight: FontWeight.w500,fontSize: 48,fontFamily: "Museo Sans Cyrillic");
  static TextStyle h2 = TextStyle(color: themeSecondaryColor,
      fontWeight: FontWeight.w500,fontSize: 24,fontFamily: "Museo Sans Cyrillic");
  static TextStyle h22 = TextStyle(color: themeBackgroundColor,
      fontWeight: FontWeight.w500,fontSize: 24,fontFamily: "Museo Sans Cyrillic");
  static TextStyle h3 = TextStyle(color: themeSecondaryColor,
      fontWeight: FontWeight.w500,fontSize: 18,fontFamily: "Museo Sans Cyrillic");
  static TextStyle h33 = TextStyle(color: themeBackgroundColor,
      fontWeight: FontWeight.w500,fontSize: 18,fontFamily: "Museo Sans Cyrillic");
  static double appWidth = Get.width;
  static double appHeight = Get.height;
  static double appTopPadding = Get.height*.125;
  static double appMiddlePadding = Get.height*.050;
  static double appSidePadding = Get.width*.10;
  static double appRadius = Get.height * 0.010;
  static double appPadding = Get.height * 0.025;
  static String appInitialRoute = '/splash';
  static String splashText = "Loading...";
  static bool splashLoader = false;
  static String logoImageURL = "assets/logo/logo.png";

  static Color splashThemeBackgroundColor = const Color(0xFF121212);
  static Color splashThemeLogoColor = const Color(0xFFF6FFFF);

  static Color themeBackgroundColor = const Color(0xFFF6FFFF);
  static Color themeMainColor = const Color(0xFF3D40F1);
  static Color themeMainColorWithOpacity = const Color(0xFF3D40F1).withOpacity(.50);
  static Color themeSecondaryColor = const Color(0xFF121212);

  static const List<IconData> BNBIconsList = [
    Icons.home,
    Icons.settings
  ];

}