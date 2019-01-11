package com.yourcompany.flutter_webview_plugin_example;

import android.os.Bundle;

import com.yourcompany.flutter_webview_plugin_example.jsapi.ActionModule;
import com.flutter_webview_plugin.jsapi.JsApiModuleEx;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
    }
}