package io.flutter.plugins;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.webkit.MimeTypeMap;
import android.widget.Toast;

import com.arvin.flutter_parse_html.BrowserActivity;
import com.arvin.flutter_parse_html.DouYinAct;
import com.arvin.flutter_parse_html.MyApplication;
import com.arvin.flutter_parse_html.PlayActivity;
import com.tencent.smtt.export.external.TbsCoreSettings;
import com.tencent.smtt.sdk.QbSdk;
import com.tencent.smtt.sdk.TbsDownloader;
import com.tencent.smtt.sdk.TbsListener;
import com.umeng.analytics.MobclickAgent;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
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
    public static final String UMENG_CHANNEL = "umeng_channel";
    public static final String GO_TO_BROWSER = "GO_TO_BROWSER";
    public static final String GO_TO_PLAY = "GO_TO_PLAY";
    public static final String LOCAL_GO_TO_PLAY = "LOCAL_GO_TO_PLAY";
    public static final String GO_TO_DOU_YIN = "GO_TO_DOU_YIN";
    public static final String GO_TO_UC_BROWSER = "GO_TO_UC_BROWSER";
    public static final String INIT_X5 = "initX5";
    public static final String HTTP_POST = "HTTP_POST";
    public static final String GO_TO_ACT = "android_go_to_act";
    public static final String IMAGE_SAVE = "android_image_save";
    public static final String STRING_ENCODE = "STRING_ENCODE";

    public static void registerLogger(FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), LOG_CHANNEL_NAME).setMethodCallHandler((methodCall, result) -> {
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

    public static void registerAct(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), GO_TO_ACT).setMethodCallHandler((methodCall, result) -> {
            if (methodCall.method.equals("act")) {
                String magnet = methodCall.argument("magnet");
                String extension = MimeTypeMap.getFileExtensionFromUrl(magnet);
                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
                Intent mediaIntent = new Intent(Intent.ACTION_VIEW);
                mediaIntent.setDataAndType(Uri.parse(magnet), mimeType);
                act.startActivity(mediaIntent);
            } else if (methodCall.method.equals("toX5Browser")) {
                if (!MyApplication.hasInit){
                    result.success(false);
                    return;
                }
                Intent intent = new Intent(act, BrowserActivity.class);
                String url = methodCall.argument("url");
                intent.putExtra("url",url);
                act.startActivity(intent);

            } else if (methodCall.method.equals("toX5Play")) {
                Intent intent = new Intent(act, BrowserActivity.class);
                String url = methodCall.argument("url");
                intent.putExtra("url",url);
                act.startActivity(intent);

            }else if (methodCall.method.equals("toBrowser")) {
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(methodCall.argument("url"));
                intent.setData(content_url);
                act.startActivity(intent);
            }else if (methodCall.method.equals("xfplay")) {
                if (isAppInstalled(act,"com.xfplay.play")){
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
                        String url = methodCall.argument("url");
                        Intent intent = act.getPackageManager().getLaunchIntentForPackage("com.xfplay.play");
                        if (intent != null){
                            intent = new Intent(Intent.ACTION_VIEW);
                            String extension = MimeTypeMap.getFileExtensionFromUrl(url);
                            String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
                            intent.setDataAndType(Uri.parse(url), mimeType);
                            act.startActivity(intent);
                        }
                    }
                }else {
//                    FlutterPluginCounter.toFlutter("noXianFeng");
                    AlertDialog.Builder builder = new AlertDialog.Builder(act);
                    builder.setTitle("提示");
                    builder.setMessage("没有安装影音先锋,是否去安装");
                    builder.setPositiveButton("是", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                            Intent intent = new Intent();
                            intent.setAction("android.intent.action.VIEW");
                            Uri content_url = Uri.parse("http://phone.xfplay.com/");
                            intent.setData(content_url);
                            act.startActivity(intent);
                        }
                    });
                    builder.setNegativeButton("否", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                        }
                    });
                    builder.show();
                }

            }
        });
    }

    //这里是判断APP中是否有相应APP的方法
    public static boolean isAppInstalled(Context context, String packageName) {
        PackageManager pm = context.getPackageManager();
        try {
            pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }

    public static void startQBrowser(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), GO_TO_BROWSER).setMethodCallHandler((methodCall, result) -> {
            if (isAppInstalled(act,"com.tencent.mtt")){
                String url = methodCall.argument("url");
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(url);
                intent.setData(content_url);
                intent.setClassName("com.tencent.mtt", "com.tencent.mtt.MainActivity");
                act.startActivity(intent);
            }else {
                Toast.makeText(act,"没有安装qq浏览器",Toast.LENGTH_SHORT).show();
            }


        });
    }


    static private void postHttp() {
        OkHttpClient client = new OkHttpClient();//创建OkHttpClient对象。
        Request request = new Request.Builder()//创建Request 对象。
                .addHeader("User-Agent","PostmanRuntime/7.26.8")
                .addHeader("x-requested-with","XMLHttpRequest")
                .url("https://cors-anywhere.herokuapp.com/https://www.xvideos.com/?k=%E7%BE%8E%E5%A5%B3&p=1")
                .get()//传递请求体
                .build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                Log.i("httpPost","返回值： " + response.body().string());
            }

            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                Log.i("httpPost","返回值： " + e.getMessage());
            }
        });//回调方法的使用与get异步请求相同，此时略。
    }

    public static void registerLocalVideoPlay(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),LOCAL_GO_TO_PLAY).setMethodCallHandler((methodCall, result) -> {
            String url = methodCall.argument("url");
            Intent intent = new Intent(Intent.ACTION_VIEW);

            String type = "video/*";

            Uri uri = Uri.parse(url);

            intent.setDataAndType(uri, type);

            act.startActivity(intent);

        });
    }

    public static void registerVideoPlay(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), GO_TO_PLAY).setMethodCallHandler((methodCall, result) -> {
            String url = methodCall.argument("url");
            String title = methodCall.argument("title");
            boolean isLive = methodCall.argument("isLive");
            PlayActivity.startAct(url,title,isLive,act);

        });
    }

    public static void registerDouYin(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), GO_TO_DOU_YIN).setMethodCallHandler((methodCall, result) -> {
            String type = methodCall.argument("type");
            DouYinAct.startAct(type,act);
        });
    }

    public static void strEncodeChange(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), STRING_ENCODE).setMethodCallHandler((methodCall, result) -> {
            String str = methodCall.argument("str");
            String oldChar = methodCall.argument("oldChar");
            String newChar = methodCall.argument("newChar");
            try {
                result.success(new String(str.getBytes(oldChar),newChar));
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

        });
    }

    public static void startUcBrowser(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), GO_TO_UC_BROWSER).setMethodCallHandler((methodCall, result) -> {
            if (isAppInstalled(act,"com.UCMobile")){
                String url = methodCall.argument("url");
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(url);
                intent.setData(content_url);
                intent.setClassName("com.UCMobile", "com.UCMobile.main.UCMobile");
                act.startActivity(intent);
            }else {
                Toast.makeText(act,"没有安装Uc浏览器",Toast.LENGTH_SHORT).show();
            }


        });
    }
    public static void registerUmeng(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), UMENG_CHANNEL).setMethodCallHandler((methodCall, result) -> {
            String event = methodCall.argument("event");
//            Toast.makeText(registrar.activeContext(),methodCall.method,Toast.LENGTH_SHORT).show();
            switch (methodCall.method) {
                case "onResume":
                    MobclickAgent.onResume(act);
                    break;
                case "onPause":
                    MobclickAgent.onPause(act);
                    break;
                case "event":
                    MobclickAgent.onEventObject(act, event, new HashMap<String, Object>());
                    break;
                default:
                    break;
            }
        });
    }

    public static void initX5Web(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), INIT_X5).setMethodCallHandler((methodCall, result) -> {
            QbSdk.setTbsListener(new TbsListener() {
                @Override
                public void onDownloadFinish(int i) {
                }
                @Override
                public void onInstallFinish(int i) {
                    Log.e("app", "onInstallFinish: 内核下载成功" );
                }
                @Override
                public void onDownloadProgress(int i) {
                }
            });
            boolean needDownload = TbsDownloader.needDownload(act, TbsDownloader.DOWNLOAD_OVERSEA_TBS);
            Log.e("app", "onCreate: "+needDownload );
            if (needDownload) {
                TbsDownloader.startDownload(act);
            }

            HashMap map = new HashMap();
            map.put(TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER, true);
            map.put(TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE, true);
            QbSdk.initTbsSettings(map);
            QbSdk.PreInitCallback cb = new QbSdk.PreInitCallback() {

                @Override
                public void onViewInitFinished(boolean arg0) {
                    MyApplication.hasInit = arg0;
                    // TODO Auto-generated method stub
                    //x5內核初始化完成的回调，为true表示x5内核加载成功，否则表示x5内核加载失败，会自动切换到系统内核。
                    Log.d("app", " onViewInitFinished is " + arg0);
//                    Toast.makeText(act,"x5内核初始化"+ (arg0?"成功":"失败"),Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onCoreInitFinished() {
                    // TODO Auto-generated method stub
                }
            };
            //x5内核初始化接口
            QbSdk.initX5Environment(act.getApplicationContext(),  cb);
        });
    }


    public static void postDataWithParame(FlutterEngine flutterEngine, Activity act) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), HTTP_POST).setMethodCallHandler((methodCall, result) -> {
            String url = methodCall.argument("url");
            HashMap<String,Object> param = methodCall.argument("param");
            OkHttpClient client = new OkHttpClient();//创建OkHttpClient对象。
            FormBody.Builder formBody = new FormBody.Builder();//创建表单请求体
            formBody.add("postid","4582");//传递键值对参数
            formBody.add("action","post_video");//传递键值对参数
            formBody.add("token","fd01a8d403");//传递键值对参数
            Request request = new Request.Builder()//创建Request 对象。
                    .url("https://www.xysp1.shop/wp-admin/admin-ajax.php")
                    .post(formBody.build())//传递请求体
                    .build();
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {

                }

                @Override
                public void onFailure(@NotNull Call call, @NotNull IOException e) {

                }
            });//回调方法的使用与get异步请求相同，此时略。
        });

    }

}
