package com.example.encrypto;
import android.app.Application;
import android.content.Context;
import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.*;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));
    }

}
