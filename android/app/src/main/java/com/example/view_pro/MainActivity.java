package com.example.view_pro;
import androidx.annotation.NonNull;
import org.jetbrains.annotations.Contract;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.java_caller";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("callJavaCodeWithMap")) {
                                java.lang.String roomName = call.argument("roomName");
                                java.lang.String roomAccessToken = call.argument("roomAccessToken");
                                java.lang.String data = callJavaCodeWithMap(roomName, roomAccessToken);
                                result.success(data);
                            }
                            else {
                                result.notImplemented();
                            }
                        });
    }

    @NonNull
    @Contract(pure = true)
    private java.lang.String callJavaCodeWithMap(java.lang.String roomName, java.lang.String roomAccessToken) {
        Log.d("myTag", "Room Name: " + roomName + " Room Access Token: " + roomAccessToken);
        return "" + roomName + " " + roomAccessToken;
    }
}

