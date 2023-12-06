// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import '../Controller/BottomNavigationBarController.dart';
import '../Utilities/AppConstants.dart';
import '../Utilities/SecureStorage.dart';
import '../Utilities/SocketConstants.dart';

class BottomNavigationBarView extends StatefulWidget {
  const BottomNavigationBarView({Key? key})
      : super(key: key);
  @override
  _BottomNavigationBarViewState createState() =>
      _BottomNavigationBarViewState();
}

class _BottomNavigationBarViewState extends State<BottomNavigationBarView> {
  _BottomNavigationBarViewState();
  DevicePlatform selectedPlatform = DevicePlatform.android;
  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavigationBarController>(builder: (controller) {
      return Scaffold(
        appBar: null,
        body: WillPopScope(
          onWillPop: null,
          child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Image at the start
                        Padding(
                          padding: EdgeInsets.all(AppConstants.appRadius),
                          child: Center(
                            child: SizedBox(
                              width: Get.width*.75,
                              height: Get.height*.175,
                              child: Image.asset(
                                'assets/logo/logo.png',
                                fit: BoxFit.contain,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: AppConstants.appHeight*0.25),
                          child: Obx(()=>Padding(
                              padding: EdgeInsets.all(AppConstants.appRadius),
                              child: GestureDetector(
                                onTap: () async {
                                  controller.workAvailabilityStatus.toggle();
                                  if(controller.workAvailabilityStatus.value == true) {
                                    await MyStorage.setCallStatus("OnActive");
                                    if (kDebugMode) {
                                      print("Status: ${controller.workAvailabilityStatus.value}");
                                      print("Call Status: OnActive");
                                    }
                                  }
                                  else if(controller.workAvailabilityStatus.value == false) {
                                    await MyStorage.setCallStatus("OnOffline");
                                    if (kDebugMode) {
                                      print("Status: ${controller.workAvailabilityStatus.value}");
                                      print("Call Status: OnOffline");
                                    }
                                  }
                                },
                                child: Container(
                                    width: AppConstants.appWidth,
                                    height: AppConstants.appWidth*0.15,
                                    decoration: BoxDecoration(
                                        color:
                                        (controller.workAvailabilityStatus.isTrue)?
                                        Colors.green:Colors.red,
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    child: Center(
                                      child: Text(
                                          (controller.workAvailabilityStatus.isTrue)?
                                          "Live":"Offline",
                                          style: const TextStyle(color: Colors.white,
                                              fontWeight: FontWeight.w500,fontSize: 32,fontFamily: "Museo Sans Cyrillic")),
                                    )
                                ),
                              )
                          )),
                        )
                      ]
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppConstants.appHeight*0.05),
                    child: Center(
                        child: GestureDetector(
                          onTap: ()
                          async {
                            // SocketConstants.socket!.disconnect();
                            await MyStorage.clearAll();
                            Get.toNamed('/logInSignUp');
                          },
                          child: Container(
                            width: AppConstants.appWidth*0.4,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.red, // Set the color of the underline to red
                                  width: 2.0,        // Set the width of the underline
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_outlined, size: 24, color: AppConstants.themeMainColor),
                                const Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24,
                                    fontFamily: "Museo Sans Cyrillic",
                                  ),
                                ),
                              ],
                            ),
                          )
                        )
                    ),
                  )
                ],
              )
          )
        )
      );
    });
  }
}