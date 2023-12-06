import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:view_pro/Utilities/SecureStorage.dart';

import '../Widgets/Custom Exit Widget.dart';

class AppStateObserver with WidgetsBindingObserver {
  // Override the didChangeAppLifecycleState method
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The app is resumed from the background
      if (kDebugMode) {
        print('App resumed from background');
      }
    } else if (state == AppLifecycleState.paused) {
      // The app is closed or moved to the background
      if (kDebugMode) {
        print('App moved to the background');
      }
    }
    else if (state == AppLifecycleState.inactive) {
      // The app is closed or moved to the background
      // setPreviousCallStatus("Yes");
      if (kDebugMode) {
        print('App closed from the background');
      }
    }
  }
  setPreviousCallStatus(String? value) async {
    await MyStorage.setPreviousCallStatus(value!);
  }
}