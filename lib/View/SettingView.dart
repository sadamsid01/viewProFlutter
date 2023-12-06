// ignore_for_file: file_names, must_be_immutable
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import '../Controller/SettingController.dart';
import '../Utilities/AppConstants.dart';
import '../Utilities/SecureStorage.dart';
import '../Utilities/SocketConstants.dart';

class SettingView extends GetView<SettingController> {

  DevicePlatform selectedPlatform = DevicePlatform.android;
  SettingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.themeBackgroundColor,
      appBar: null,
      body: Obx(
            () => SettingsList(
              lightTheme: SettingsThemeData
                (
                settingsListBackground: AppConstants.themeBackgroundColor,
                settingsSectionBackground: AppConstants.themeBackgroundColor,
                settingsTileTextColor: AppConstants.themeBackgroundColor,
              ),
              platform: selectedPlatform,
              sections: [
                SettingsSection(
                  title: Text('Account',style: AppConstants.h2,),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      onPressed: (value) async
                      {
                        SocketConstants.socket!.disconnect();
                        await MyStorage.clearAll();
                        Get.toNamed('/logInSignUp');
                      },
                      leading: Icon(Icons.logout_outlined,color: AppConstants.themeMainColor,),
                      title: Text('Sign out',style: AppConstants.h3,),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text('Accessibility',style: AppConstants.h2,),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        controller.workAvailabilityStatus.value = value;
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
                      initialValue: controller.workAvailabilityStatus.value,
                      leading: Icon(Icons.event_available_outlined,color: AppConstants.themeMainColor,),
                      title: Text('Available',style: AppConstants.h3,),
                      activeSwitchColor: AppConstants.themeMainColor,
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }
}