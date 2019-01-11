package com.flutter_webview_plugin.model;

/**
 * Created by levyyoung on 14-5-26.
 */

public class ResultData {
    public ResultData() {
    }

    public ResultData(int code) {
        this.code = code;
    }

    public ResultData(int code, String msg, Object data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    public int code = 0;
    public String msg = "";
    public Object data = "";
}
