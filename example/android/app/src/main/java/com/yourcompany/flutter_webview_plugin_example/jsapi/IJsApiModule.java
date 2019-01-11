package com.yourcompany.flutter_webview_plugin_example.jsapi;

import android.content.Context;

public interface IJsApiModule {

    String moduleName();

    String invoke(String method, String param, IJSCallback callback, Context context);

    void release();

    interface IJSCallback {
        void invokeCallback(String param);
    }

    interface IJsApiMethod {
        String methodName();
        String invoke(String param, IJSCallback callback, Context activity);
    }


}