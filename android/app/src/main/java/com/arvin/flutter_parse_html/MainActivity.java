package com.arvin.flutter_parse_html;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Point;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.Display;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import com.tencent.smtt.sdk.QbSdk;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.PushAgent;

import androidx.annotation.RequiresApi;
import androidx.multidex.MultiDex;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.CustomFlutterPlugins;
import io.flutter.plugins.FlutterPluginCounter;

public class MainActivity extends FlutterActivity {
  final  int INSTALL_PERMISS_CODE = 100;
  private  QbSdk.PreInitCallback cb;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    MultiDex.install(this);
//    GeneratedPluginRegistrant.registerWith(this);
//    CustomFlutterPlugins.registerLogger(getFlutterView());
//    CustomFlutterPlugins.registerAct(registrarFor(CustomFlutterPlugins.GO_TO_ACT));
//    CustomFlutterPlugins.registerUmeng(registrarFor(CustomFlutterPlugins.UMENG_CHANNEL));
//    FlutterPluginCounter.registerWith(registrarFor(FlutterPluginCounter.CHANNEL));
//    setStatus(this);
  }



  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    CustomFlutterPlugins.registerLogger(flutterEngine);
    CustomFlutterPlugins.registerAct(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    CustomFlutterPlugins.registerUmeng(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    CustomFlutterPlugins.startQBrowser(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    CustomFlutterPlugins.registerVideoPlay(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    CustomFlutterPlugins.registerDouYin(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    CustomFlutterPlugins.startUcBrowser(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    CustomFlutterPlugins.initX5Web(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    FlutterPluginCounter.registerWith(flutterEngine, com.arvin.flutter_parse_html.MainActivity.this);
    UMConfigure.init(this,"5ddc8b37570df395b0000af1", "",UMConfigure.DEVICE_TYPE_PHONE, "e9b52e22a332d3c9e3b04627faa88aaf");
    PushAgent mPushAgent = PushAgent.getInstance(this);
//注册推送服务，每次调用register方法都会回调该接口
    mPushAgent.register(new IUmengRegisterCallback() {
      @Override
      public void onSuccess(String deviceToken) {
        //注册成功会返回deviceToken deviceToken是推送消息的唯一标志
        Log.i("umeng","注册成功：deviceToken：-------->  " + deviceToken);
      }
      @Override
      public void onFailure(String s, String s1) {
        Log.e("umeng","注册失败：-------->  " + "s:" + s + ",s1:" + s1);
      }
    });
    //搜集本地tbs内核信息并上报服务器，服务器返回结果决定使用哪个内核。
    setInstallPermission();
    cb = new QbSdk.PreInitCallback() {

      @Override
      public void onViewInitFinished(boolean arg0) {
        MyApplication.hasInit = arg0;
        // TODO Auto-generated method stub
        //x5內核初始化完成的回调，为true表示x5内核加载成功，否则表示x5内核加载失败，会自动切换到系统内核。
        Log.d("app", " onViewInitFinished is " + arg0);
                Toast.makeText(getApplicationContext(),"初始化"+arg0,Toast.LENGTH_SHORT).show();
      }

      @Override
      public void onCoreInitFinished() {
        // TODO Auto-generated method stub
      }
    };
    //x5内核初始化接口
//    QbSdk.initX5Environment(getApplicationContext(),  cb);
  }

  public void setStatus(Activity activity){
    if(!isNavigationBarShow(activity)) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);//窗口透明的状态栏
        activity.requestWindowFeature(Window.FEATURE_NO_TITLE);//隐藏标题栏
        activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);//窗口透明的导航栏
      }
    }else{
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        activity.getWindow().setStatusBarColor(Color.TRANSPARENT);
      }
    }
  }

  //是否是虚拟按键的设备
  @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
  private boolean isNavigationBarShow(Activity activity){
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
      Display display = activity.getWindowManager().getDefaultDisplay();
      Point size = new Point();
      Point realSize = new Point();
      display.getSize(size);
      display.getRealSize(realSize);
      boolean  result  = realSize.y!=size.y;
      return realSize.y!=size.y;
    }else {
      boolean menu = ViewConfiguration.get(activity).hasPermanentMenuKey();
      boolean back = KeyCharacterMap.deviceHasKey(KeyEvent.KEYCODE_BACK);
      if(menu || back) {
        return false;
      }else {
        return true;
      }
    }
  }

  /**
   * 8.0以上系统设置安装未知来源权限
   */
  public void setInstallPermission(){
    boolean haveInstallPermission;
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
      //先判断是否有安装未知来源应用的权限
      haveInstallPermission = getPackageManager().canRequestPackageInstalls();
      if(!haveInstallPermission){
        //弹框提示用户手动打开
        showAlert(this, "安装权限", "x5播放器需要打开此权限，请去设置中开启此权限", new View.OnClickListener() {
          @Override
          public void onClick(View view) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              //此方法需要API>=26才能使用
              toInstallPermissionSettingIntent();
            }
          }
        });
        return;
      }
    }
  }


  /**
   * 开启安装未知来源权限
   */
  @RequiresApi(api = Build.VERSION_CODES.O)
  private void toInstallPermissionSettingIntent() {
    Uri packageURI = Uri.parse("package:"+getPackageName());
    Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,packageURI);
    startActivityForResult(intent, INSTALL_PERMISS_CODE);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    if (resultCode == RESULT_OK && requestCode == INSTALL_PERMISS_CODE) {
//      Toast.makeText(this,"安装应用",Toast.LENGTH_SHORT).show();
    }
  }

  /**
   * alert 消息提示框显示
   * @param context   上下文
   * @param title     标题
   * @param message   消息
   * @param listener  监听器
   */
  public  void showAlert(Context context, String title, String message, View.OnClickListener listener){
    new CommonDialog(context).setTitle(title)
            .setContent(message)
            .setPositiveButton("确定",listener).build().show();
  }
  /**
   * 重启app
   * @param context
   */
  public void restartApp(Context context) {
    PackageManager packageManager = context.getPackageManager();
    if (null == packageManager) {
      return;
    }
    final Intent intent = packageManager.getLaunchIntentForPackage(context.getPackageName());
    if (intent != null) {
      intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
      context.startActivity(intent);
    }
  }
}
