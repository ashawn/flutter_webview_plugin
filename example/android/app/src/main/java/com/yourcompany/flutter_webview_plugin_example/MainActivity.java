package com.yourcompany.flutter_webview_plugin_example;

import android.os.Bundle;

import com.flutter_webview_plugin.util.JsonParser;
import com.moschat.mobile.framework.util.ShareUtil;
import com.yourcompany.flutter_webview_plugin_example.jsapi.ActionModule;
import com.flutter_webview_plugin.jsapi.JsApiModuleEx;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "webview_native_invoke";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(),CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                if (methodCall.method.equals("nativeShare")) {
                    String url = methodCall.argument("url");
                    ShareUtil.INSTANCE.shareLink(MainActivity.this, url);
                }
            }
        });
    }
}