package com.flutter_webview_plugin.util;

import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Auto parse json string to object
 *
 * @author <a href="mailto:kuanglingxuan@yy.com">匡凌轩</a> 2014-6-10
 *         Created by zhongyongsheng on 14-4-11.
 */
public class JsonParser {

    public static Gson gson = new GsonBuilder()
            .disableHtmlEscaping() //Gson将对象类转成Json对象时 = 出现\u003d的问题
            .create();

    static {
    }


    /**
     * parse json string to object
     *
     * @param json
     * @param clz
     * @param <T>
     * @return
     * @throws java.io.IOException
     */
    public static <T> T parseJsonObject(String json, Class<T> clz) {
        return gson.fromJson(json, clz);
    }

    public static <T> T parseJsonObject(JsonElement json, Class<T> clz) {
        return gson.fromJson(json, clz);
    }

    /**
     * parse json string to Array
     *
     * @param clz
     * @return
     * @throws Exception
     */
    public static <T> T[] parseJsonArray(String json, Class<T> clz) {
        T[] result = gson.fromJson(json, new TypeToken<T[]>() {
        }.getType());
        return result;
    }

    /**
     * parse json string to Map
     *
     * @param json
     * @param keyType
     * @param valueType
     * @param <K>
     * @param <V>
     * @return
     */
    public static <K, V> Map<K, V> parseJsonMap(String json, Class<K> keyType, Class<V> valueType) {
        Map<K, V> result = gson.fromJson(json,
                new TypeToken<Map<K, V>>() {
                }.getType());
        return result;
    }


    public static String toJson(Object obj) {
        try {
            return gson.toJson(obj);
        } catch (Throwable e) {
            Log.e("JsonParser", "wangsong", e);
            return "{}";
        }
    }

    private static class NumberTypeAdapter implements JsonSerializer<Number> {
        @Override
        public JsonElement serialize(Number src, Type typeOfSrc, JsonSerializationContext context) {
            return new JsonPrimitive(src);
        }
    }

    public static <T> List<T> parseJsonList(String json, Class<T> clz) throws Exception {
        List<T> data = new ArrayList<T>();
        if (!TextUtils.isEmpty(json)) {
            com.google.gson.JsonParser parser = new com.google.gson.JsonParser();
            JsonElement element = parser.parse(json);
            JsonArray array = element.getAsJsonArray();
            for (JsonElement jo : array) {
                data.add(gson.fromJson(jo, clz));
            }
        }
        return data;
    }

    public static <T> List<T> parseJsonList(JsonArray array, Class<T> clz) throws Exception {
        List<T> data = new ArrayList<T>();
        for (JsonElement jo : array) {
            data.add(parseJsonObject(jo, clz));
        }
        return data;
    }

}