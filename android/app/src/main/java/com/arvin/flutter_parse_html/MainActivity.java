package com.arvin.flutter_parse_html;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.CustomFlutterPlugins;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    CustomFlutterPlugins.registerLogger(getFlutterView());
    CustomFlutterPlugins.registerAct(registrarFor(CustomFlutterPlugins.GO_TO_ACT));
  }
}
