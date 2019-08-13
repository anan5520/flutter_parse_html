package io.flutter.plugins;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.webkit.MimeTypeMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * * Copyright (C) 2018 爱瑞智健康科技（北京）有限公司
 * 爱瑞智完全享有此软件的著作权，违者必究
 *
 * @author an
 * @createDate 2019/7/11
 * @description
 */
public class CustomFlutterPlugins {

    //这里必选要跟Flutter平台名称对应上，否则无法接收消息
    private static final String LOG_CHANNEL_NAME = "android_log";
    public static final String GO_TO_ACT = "android_go_to_act";

    public static void registerLogger(BinaryMessenger messenger) {
        new MethodChannel(messenger, LOG_CHANNEL_NAME).setMethodCallHandler((methodCall, result) -> {
            String tag = methodCall.argument("tag");
            String msg = methodCall.argument("msg");
            switch (methodCall.method) {
                case "logV":
                    Log.v(tag, msg);
                    break;
                case "logD":
                    Log.d(tag, msg);
                    break;
                case "logI":
                    Log.i(tag, msg);
                    break;
                case "logW":
                    Log.w(tag, msg);
                    break;
                case "logE":
                    Log.e(tag, msg);
                    break;
                default:
                    Log.d(tag, msg);
                    break;
            }
        });
    }

    public static void registerAct(PluginRegistry.Registrar registrar) {
        new MethodChannel(registrar.messenger(), GO_TO_ACT).setMethodCallHandler((methodCall, result) -> {
            if (methodCall.method.equals("act")) {
                String magnet = methodCall.argument("magnet");
                String extension = MimeTypeMap.getFileExtensionFromUrl(magnet);
                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
                Intent mediaIntent = new Intent(Intent.ACTION_VIEW);
                mediaIntent.setDataAndType(Uri.parse(magnet), mimeType);
                registrar.activity().startActivity(mediaIntent);
            } else if (methodCall.method.equals("toBrowser")) {
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(methodCall.argument("url"));
                intent.setData(content_url);
                registrar.activity().startActivity(intent);
            }else if (methodCall.method.equals("xfplay")) {

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
                    String url = methodCall.argument("url");
                    Intent intent = registrar.activity().getPackageManager().getLaunchIntentForPackage("com.xfplay.play");
                    if (intent != null){
                        intent = new Intent(Intent.ACTION_VIEW);
                        String extension = MimeTypeMap.getFileExtensionFromUrl(url);
                        String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
                        intent.setDataAndType(Uri.parse(url), mimeType);
                        registrar.activity().startActivity(intent);
                    }
                }
            }
        });
    }

    //这里是判断APP中是否有相应APP的方法
    private boolean isAppInstalled(Context context, String packageName) {
        try {
            context.getPackageManager().getPackageInfo(packageName,0);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
