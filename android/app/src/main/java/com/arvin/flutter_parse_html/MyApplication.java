package com.arvin.flutter_parse_html;

import android.util.Log;

import com.tencent.smtt.sdk.QbSdk;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.PushAgent;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {

    public static boolean hasInit = false;

    @Override
    public void onCreate() {
        super.onCreate();

    }
}
