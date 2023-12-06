import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Utilities/SecureStorage.dart';

class CustomSplashScreen extends StatelessWidget {
  final Image logo;
  final double logoWidth;
  final Color backgroundColor;
  final int durationInSeconds;

  const CustomSplashScreen({
    super.key,
    required this.logo,
    required this.logoWidth,
    required this.backgroundColor,
    required this.durationInSeconds,
  });

  @override
  Widget build(BuildContext context) {
    // Using GetX for navigation
    Future.delayed(Duration(seconds: durationInSeconds), () async {
      bool? checkForAccessToken = await MyStorage.checkForAccessToken();
      if(checkForAccessToken == true)
      {
        MyStorage.setCallStatus("OnActive");
        if (kDebugMode) {
          print("CheckForAccessToken Status: $checkForAccessToken");
          print("User is already Logged In");
          print("Call Status: OnActive");
          Get.offNamed("/bnb");
        }
      }
      else {
        MyStorage.setCallStatus("OnPending");
        if (kDebugMode) {
          print("CheckForAccessToken Status: $checkForAccessToken");
          print("User is Not Logged In");
          print("Call Status: OnPending");
          Get.offNamed("/logInSignUp");
        }
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SizedBox(
          width: logoWidth,
          child: logo,
        ),
      ),
    );
  }
}
