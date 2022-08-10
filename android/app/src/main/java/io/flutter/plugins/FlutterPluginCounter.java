package io.flutter.plugins;

import android.app.Activity;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;

public class FlutterPluginCounter implements EventChannel.StreamHandler {

    public static String CHANNEL = "native/plugin";

    static EventChannel channel;

    private Activity activity;
    private static EventChannel.EventSink mEventSink;

    private FlutterPluginCounter(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(FlutterEngine flutterEngine,Activity act) {
        channel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        FlutterPluginCounter instance = new FlutterPluginCounter(act);
        channel.setStreamHandler(instance);
    }

    public static void toFlutter(String event){
        if (mEventSink != null){
            mEventSink.success(event);
        }
    }

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
    }

}