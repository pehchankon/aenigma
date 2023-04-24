package com.pehchankon.aenigma;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import android.os.*;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.List;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.content.ContextWrapper;
import android.widget.Toast;
import android.view.inputmethod.*;

public class MainActivity extends FlutterActivity {
  static final String BATTERY_CHANNEL = "testing/keys";
  private MethodChannel channel;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BATTERY_CHANNEL);
    channel.setMethodCallHandler(
        (call, result) -> {
          if (call.method.equals("setKey")) {
            String pass = call.argument("password");
            String alias = call.argument("alias");
            keyboard.setKeyValue(pass,alias);
            result.success(true);
          } else if (call.method.equals("setTimer")) {
            int timerValue = call.argument("timer");
            boolean isEnabled = call.argument("enabled");
            keyboard.setTimer(timerValue,isEnabled);
            result.success(timerValue);
          } else if (call.method.equals("checkInputMethods")) {
            InputMethodManager imeManager = (InputMethodManager) getApplicationContext()
                .getSystemService(INPUT_METHOD_SERVICE);
            List<InputMethodInfo> inputMethods = imeManager.getEnabledInputMethodList();
            for (int i = 0; i < inputMethods.size(); i++) {
              if (inputMethods.get(i).getServiceName().equals("com.pehchankon.aenigma.keyboard"))
                {result.success(true);
                return;}
            }
            result.success(false);
          } else {
            result.notImplemented();
          }
        });

  }
}
