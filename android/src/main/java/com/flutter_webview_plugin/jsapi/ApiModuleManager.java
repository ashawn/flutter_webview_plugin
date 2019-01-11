package com.flutter_webview_plugin.jsapi;

import android.text.TextUtils;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * created by jyk on 2019/1/8.
 */
public class ApiModuleManager implements IApiModuleManager {
    public static final String TAG = ApiModuleManager.class.getSimpleName();

    private List<String> apiModuleList = new ArrayList<>();

    public ApiModuleManager() {
        /*
         * 数据API在此静态注册
         * UI上下文相关API在ACT动态注册
         * */
    }

    @Override
    public void addModule(String apiModule) {
        if (!TextUtils.isEmpty(apiModule)) {
            apiModuleList.add(apiModule);
        } else {
            Log.w(TAG, "invalid module name, skip mapping.");
        }
    }

    @Override
    public void removeModule(String apiModule) {
        apiModuleList.remove(apiModule);
    }

    @Override
    public void removeModuleByName(String name) {

    }


    public void release() {
        apiModuleList.clear();
    }
}
