package com.flutter_webview_plugin.jsapi;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.ContactsContract;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;

import com.flutter_webview_plugin.FlutterWebviewPlugin;
import com.flutter_webview_plugin.model.ResultData;
import com.flutter_webview_plugin.util.JsonParser;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

/**
 * created by jyk on 2019/1/8.
 */
public class JavaScriptInterface {

    public static final String TAG = JavaScriptInterface.class.getSimpleName();

    private WeakReference<WebView> webViewHolder = null;
    private ApiModuleManager v2ApiModuleManager = new ApiModuleManager();



    public JavaScriptInterface(WebView view) {
        if (view != null) {
            webViewHolder = new WeakReference<>(view);
        }
    }

    public void addApiModule(String module) {
        v2ApiModuleManager.addModule(module);
    }

    public void removeApiModule(String moduleName) {
        v2ApiModuleManager.removeModule(moduleName);
    }

    @TargetApi(11)
    public void release() {
        if (webViewHolder != null) {
            WebView webView = webViewHolder.get();
            if (webView != null) {
                if (Build.VERSION.SDK_INT > Build.VERSION_CODES.HONEYCOMB) {
                    webView.removeJavascriptInterface("AndroidJSInterfaceV2");
                }
            }
        }
        if (v2ApiModuleManager != null) {
            v2ApiModuleManager.release();
        }
    }

    @JavascriptInterface
    public String invoke(final String module, final String name, final String parameters, final String callback) {
        try {
            if (!TextUtils.isEmpty(module)) {
                Context context = null;
                if (webViewHolder.get() != null) {
                    context = webViewHolder.get().getContext();
                }
                Map<String, Object> data = new HashMap<>();
                data.put("module", module);
                data.put("name",name);
                data.put("parameters", parameters);
                data.put("callback", callback);
                FlutterWebviewPlugin.channel.invokeMethod("onJsApiCalled", data, new MethodChannel.Result() {
                    @Override
                    public void success(Object o) {
                        if (o != null) {
                            Log.d(TAG,o.toString());
                        }
                    }

                    @Override
                    public void error(String s, String s1, Object o) {

                    }

                    @Override
                    public void notImplemented() {

                    }
                });
                // String result = apiModule.invoke(name, parameters, genJSCallback(callback), context);
                // Log.d(TAG, "invoke [result:" + result + "]");
                // return result;
            }
        } catch (Throwable throwable) {
            Log.e(TAG,"invoke module = " + module + ", name = " + name + ", parameters = " + parameters + ", error happen e = " + throwable, throwable);
        }
        return JsonParser.toJson(new ResultData(-1));
    }



}
