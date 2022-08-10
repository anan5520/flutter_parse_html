package com.arvin.flutter_parse_html;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.transition.Transition;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.arvin.flutter_parse_html.model.VideoModel;
import com.arvin.flutter_parse_html.video.SampleVideo;
import com.shuyu.gsyvideoplayer.GSYVideoManager;
import com.shuyu.gsyvideoplayer.utils.OrientationUtils;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import io.flutter.plugins.CustomFlutterPlugins;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class DouYinAct extends AppCompatActivity {

    public final static String IMG_TRANSITION = "IMG_TRANSITION";
    public final static String TRANSITION = "TRANSITION";


    OrientationUtils orientationUtils;

    private boolean isTransition;

    private Transition transition;

    private SampleVideo videoPlayer;

    private List<VideoModel> data;

    private int index = 0;

    private boolean isLooping = true;

    private ProgressDialog progressDialog;

    private boolean isGetting = false;

    private String currentUrl;

    private TextView tvDownload;

    private String type;

    private OkHttpClient client;

    /**
     * @param type
     * @param context
     */
    public static void startAct(String type, Context context){
        Intent intent = new Intent(context,DouYinAct.class);
        intent.putExtra("type",type);
        context.startActivity(intent);

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_douyin);
        videoPlayer = findViewById(R.id.video_player);
        tvDownload = findViewById(R.id.tv_download);
        isTransition = getIntent().getBooleanExtra(TRANSITION, false);
        init();
    }

    private void init() {
        data = new ArrayList<>();
        type = getIntent().getStringExtra("type");
        String name = "标准";


        //增加title
        videoPlayer.getTitleTextView().setVisibility(View.VISIBLE);
        //videoPlayer.setShowPauseCover(false);

        //videoPlayer.setSpeed(2f);

        videoPlayer.setLooping(false);

        //设置返回键
        videoPlayer.getBackButton().setVisibility(View.VISIBLE);
        videoPlayer.setStartAfterPrepared(true);
        //设置旋转
        orientationUtils = new OrientationUtils(this, videoPlayer);

        //设置全屏按键功能,这是使用的是选择屏幕，而不是全屏
        videoPlayer.getFullscreenButton().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                orientationUtils.resolveByClick();
            }
        });

        //设置返回按键功能
        videoPlayer.getBackButton().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        videoPlayer.setVideoAllCallBack(new VideoCallBack() {
            @Override
            public void onPlayError(String url, Object... objects) {
                super.onPlayError(url, objects);
                if (index == data.size()){
                    getData();
                }else {
                    playVideo();
                }

            }

            @Override
            public void onAutoComplete(String url, Object... objects) {
                super.onComplete(url, objects);
                if (!isLooping){
                    if (index == data.size()){
                        getData();
                    }else {
                        playVideo();
                    }
                }else {
                    videoPlayer.startPlayLogic();
                }
            }
        });
        findViewById(R.id.ll_next).setOnClickListener(view -> {
            getData();
        });
        TextView tvLooping = findViewById(R.id.tv_looping);
        findViewById(R.id.ll_is_looping).setOnClickListener(view -> {
            if (isLooping){
                tvLooping.setText("自动跳");
                isLooping = false;
            }else {
                isLooping = true;
                tvLooping.setText("循环播");
            }
        });
        findViewById(R.id.ll_previous).setOnClickListener(view -> {
            if (index > 1){
                index =-2;
                playVideo();
            }

        });
        findViewById(R.id.ll_download).setOnClickListener(view -> {
            if (CustomFlutterPlugins.isAppInstalled(this,"com.UCMobile")){
                String url = currentUrl;
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(url);
                intent.setData(content_url);
                intent.setClassName("com.UCMobile", "com.UCMobile.main.UCMobile");
                startActivity(intent);
            }else {
                Toast.makeText(this,"没有安装Uc浏览器",Toast.LENGTH_SHORT).show();
            }


        });
        //过渡动画
        initTransition();
        getData();
    }


    @Override
    protected void onPause() {
        super.onPause();
        videoPlayer.onVideoPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        videoPlayer.onVideoResume();
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (orientationUtils != null)
            orientationUtils.releaseListener();
    }

    @Override
    public void onBackPressed() {
        //先返回正常状态
        if (orientationUtils.getScreenType() == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            videoPlayer.getFullscreenButton().performClick();
            return;
        }
        //释放所有
        videoPlayer.setVideoAllCallBack(null);
        GSYVideoManager.releaseAllVideos();
        if (isTransition && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            super.onBackPressed();
        } else {
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    finish();
                    overridePendingTransition(R.anim.abc_fade_in, R.anim.abc_fade_out);
                }
            }, 500);
        }
    }


    private void initTransition() {
        if (isTransition && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            postponeEnterTransition();
            ViewCompat.setTransitionName(videoPlayer, IMG_TRANSITION);
            addTransitionListener();
            startPostponedEnterTransition();
        } else {
            videoPlayer.startPlayLogic();
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private boolean addTransitionListener() {
        transition = getWindow().getSharedElementEnterTransition();
        if (transition != null) {
            transition.addListener(new Transition.TransitionListener(){
                @Override
                public void onTransitionStart(Transition transition) {

                }

                @Override
                public void onTransitionEnd(Transition transition) {
                    videoPlayer.startPlayLogic();
                    transition.removeListener(this);
                }

                @Override
                public void onTransitionCancel(Transition transition) {

                }

                @Override
                public void onTransitionPause(Transition transition) {

                }

                @Override
                public void onTransitionResume(Transition transition) {

                }
            });
            return true;
        }
        return false;
    }

     private void getData() {
        if (isGetting)
            return;
         isGetting = true;
        showDialog();
        String url;
        if (TextUtils.isEmpty(type) || "0".equals(type)){
            String[] indexs = new String[]{"1","2","3", "4", "5", "6", "8", "9"};
            int index = new Random().nextInt(indexs.length);
            //http://www.quanbaike.com/tool/ksxjj/video.php?_t=
            url = String.format("%s%s.php","https://mm.diskgirl.com/get/get",indexs[index]);
        }else {
            url = String.format("%s%s.json","https://xn--pru35wv4hgss92q.xyz/json/",new Random().nextInt(4658));
        }
        if (client == null){
            client = new OkHttpClient();//创建OkHttpClient对象。
        }
        Request request = new Request.Builder()//创建Request 对象。
                .addHeader("User-Agent","PostmanRuntime/7.26.8")
                .url(url)
                .get()//传递请求体
                .build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                isGetting = false;
                dismissDialog();
                String body = response.body().string();
                Log.i("httpPost","返回值： " + body);
                VideoModel videoModel = new VideoModel();
                if (TextUtils.isEmpty(type) || "0".equals(type)){
                    //                if (body.contains(".mp4") && !body.endsWith("mp4")) {
//                    String[] strings = body.split(".mp4");
//                    videoModel.setUrl(strings[0] + ".mp4");
//                } else
                    if (!body.startsWith("http")) {
                        videoModel.setUrl("https:" + body);
                    } else {
                        videoModel.setUrl(body);
                    }
                }else {
                    try {
                        JSONObject jsonObject = new JSONObject(body);
                        videoModel.setUrl(jsonObject.getString("url"));
                        videoModel.setTitle(jsonObject.getString("name"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                data.add(videoModel);
                playVideo();
            }

            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                isGetting = false;
                dismissDialog();
                Log.i("httpPost","返回值： " + e.getMessage());
            }
        });//回调方法的使用与get异步请求相同，此时略。
    }

    private void playVideo() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (index < data.size()){
                    String url = data.get(index).getUrl();
                    String title = data.get(index).getTitle();
                    currentUrl = url;
                    videoPlayer.setUp(url, true, !TextUtils.isEmpty(title)?title:"抖音");
                    videoPlayer.startPlayLogic();
                    index ++;
                }
            }
        });


    }

    private void showDialog(){
        progressDialog = new ProgressDialog().buildDialog(this);
        progressDialog.show();
    }

    private void dismissDialog(){
        if (progressDialog != null)
            progressDialog.dismiss();
    }

}
