package com.yourcompany.flutter_webview_plugin_example.jsapi;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.flutter_webview_plugin.model.ResultData;
import com.flutter_webview_plugin.util.JsonParser;
import com.moschat.mobile.framework.util.ShareUtil;

import org.json.JSONObject;

/**
 * created by jyk on 2019/1/8.
 */
public class ActionModule implements IJsApiModule {

    public static final String TAG = ActionModule.class.getSimpleName();
    private static final String MODULE_NAME = "action";

    public ActionModule(){
        Log.d(TAG, "init actionModule");
    }

    @Override
    public String moduleName() {
        return MODULE_NAME;
    }

    @Override
    public String invoke(String method, String param, IJSCallback callback, Context context) {
        Log.d(TAG, "method" + method);
        Log.d(TAG, "param" + param);
        String returnValue = "";
        if (nativeShare.methodName().equals(method)) {
            returnValue = nativeShare.invoke(param, callback, context);
        }
        return returnValue;
    }



    @Override
    public void release() {

    }

    // private IJsApiMethod convertBase64ToImage = new IJsApiMethod() {
    //     @Override
    //     public String methodName() {
    //         return "nativePhotoSave";
    //     }
    //
    //     @Override
    //     public String invoke(String param, IJSCallback callback, Context context) {
    //         Log.i(TAG, "[nativePhotoSave].param=" + param);
    //         final String[] resultParam = new String[1];
    //         try {
    //             JSONObject jsonObject = new JSONObject(param);
    //
    //             String imageBase64 = jsonObject.optString("base64uri");
    //             if (TextUtils.isEmpty(imageBase64)) {
    //                 resultParam[0] = JsonParser.toJson(new ResultData(1, "", ""));
    //                 callback.invokeCallback(resultParam[0]);
    //                 return resultParam[0];
    //             }
    //
    //             if (context instanceof Activity) {
    //                 BaseActivity activity = (BaseActivity) context;
    //                 activity.performCodeWithPermission(new BaseActivity.PermissionCallback() {
    //                     @Override
    //                     public void hasPermission() {
    //                         File dir = new File(BasicConfig.getInstance().getRootDir() + "/saved_images");
    //                         dir.mkdirs();
    //
    //                         String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
    //                         String fname = "moschat_"+ timeStamp +".jpg";
    //
    //                         File file = new File(dir, fname);
    //                         if (file.exists()) {
    //                             file.delete();
    //                         }
    //
    //                         if (WebViewUtils.handleBase64ToImage(imageBase64, file.getPath())) {
    //                             Toast.makeText(context, context.getText(R.string.save_to) + " " + dir.getAbsolutePath(), Toast.LENGTH_LONG).show();
    //                             RuntimeInfo.sAppContext.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)));
    //                             resultParam[0] = JsonParser.toJson(new ResultData(0, "", ""));
    //                             callback.invokeCallback(resultParam[0]);
    //                         } else {
    //                             resultParam[0] = JsonParser.toJson(new ResultData(1, "", ""));
    //                             callback.invokeCallback(resultParam[0]);
    //                         }
    //
    //                     }
    //
    //                     @Override
    //                     public void noPermission() {
    //                     }
    //                 }, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE);
    //
    //             }
    //
    //         } catch (Throwable e) {
    //             KLog.e(TAG, "[WebInterface].[ActionModule].[nativePhotoSave]", e);
    //             resultParam[0] = JsonParser.toJson(new ResultData(1, "", ""));
    //             callback.invokeCallback(resultParam[0]);
    //             return resultParam[0];
    //         }
    //         return JsonParser.toJson(new ResultData(0, "", ""));
    //     }
    // };

    private IJsApiMethod nativeShare = new IJsApiMethod() {
        @Override
        public String methodName() {
            return "nativeShare";
        }

        @Override
        public String invoke( String param,  IJSCallback callback, Context context) {
            Log.i(TAG, "[nativeShare].param=" + param);
            String resultParam;

            try {
                JSONObject jsonObject = new JSONObject(param);

                String shareDesc = jsonObject.optString("sharedesc");
                String shareUrl = jsonObject.optString("shareuri");
                if (TextUtils.isEmpty(shareUrl)) {
                    resultParam = JsonParser.toJson(new ResultData(1, "", ""));
                    callback.invokeCallback(resultParam);
                    return resultParam;
                }

                // to share
                if (context != null && context instanceof Activity) {
                    ShareUtil.INSTANCE.shareLink((Activity) context, shareDesc + "\n" + shareUrl);
                    resultParam = JsonParser.toJson(new ResultData(0, "", ""));
                    callback.invokeCallback(resultParam);
                    return resultParam;
                } else {
                    resultParam = JsonParser.toJson(new ResultData(1, "", ""));
                    callback.invokeCallback(resultParam);
                    return resultParam;
                }

            } catch (Throwable e) {
                Log.e(TAG, "[WebInterface].[ActionModule].[nativeShare]", e);
                resultParam = JsonParser.toJson(new ResultData(1, "", ""));
                callback.invokeCallback(resultParam);
                return resultParam;
            }
        }
    };
}
