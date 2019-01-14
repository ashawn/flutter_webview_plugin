package com.moschat.mobile.framework.util

import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import com.flutter_webview_plugin.R
import java.lang.Exception

/**
 * Created by Amos.Pan on 2018/7/18
 *
 */
object ShareUtil {



    fun shareLink(ctx: Activity?, url: String) {
        if (ctx != null) {
            Intent()
            var sharedConfig = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                putExtra(Intent.EXTRA_SUBJECT, "share_title")
                putExtra(Intent.EXTRA_TEXT, url)
            }

            var shareIntent = Intent.createChooser(sharedConfig, "lalallalallalalla")
            ctx.startActivity(shareIntent)
        }
    }


    fun shareFlutterImg(ctx: Activity?, uri: Uri, title: String) {
        if (ctx != null) {
            var sharedConfig = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/jpeg"
                putExtra(Intent.EXTRA_SUBJECT, title)
                putExtra(Intent.EXTRA_TEXT, uri)
            }

            var shareIntent = Intent.createChooser(sharedConfig, title)
            ctx.startActivity(shareIntent)
        }
    }

    fun shareFlutterUrl(ctx: Activity?,content: String, title: String, subject: String) {
        if (ctx != null) {
            var sharedConfig = Intent().apply {
                action = Intent.ACTION_SEND
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, content)
                putExtra(Intent.EXTRA_SUBJECT, subject)
            }
            var shareIntent = Intent.createChooser(sharedConfig, title)
            ctx.startActivity(shareIntent)
        }
    }

    fun stringToBitmap(content: String) {
        try {
            val bitmapArray = Base64.decode(content.split(",")[1], Base64.DEFAULT)
            val bitmap = BitmapFactory.decodeByteArray(bitmapArray, 0, bitmapArray.size)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

}