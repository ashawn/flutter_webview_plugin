package com.flutter_webview_plugin.jsapi;

import android.widget.ProgressBar;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * created by jyk on 2019/1/10.
 */
public class JsApiModuleEx {

    private static final JsApiModuleEx INSTANCE = new JsApiModuleEx();
    private List<String> modules = new ArrayList<>();

    private JsApiModuleEx() {
    }

    public static JsApiModuleEx getInstance() {
        return INSTANCE;
    }

    public List<String> getModules(){
        return modules;
    }

    public void addJsApiModule(String iJsApiModule) {
        modules.remove(iJsApiModule);
        modules.add(iJsApiModule);
    }

}