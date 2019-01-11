package com.flutter_webview_plugin.jsapi;

public interface IApiModuleManager {
    void addModule(String apiModule);

    void removeModule(String apiModule);

    void removeModuleByName(String name);
}