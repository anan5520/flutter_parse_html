import 'package:flutter/services.dart';

class NativeUtils {
  static const perform = const MethodChannel("android_go_to_act");

  static void toAct(String magnet) {
    perform.invokeMethod('act', {'magnet': magnet});
  }

  static void toBrowser(String url) {
    perform.invokeMethod('toBrowser', {'url': url});
  }
  static void toXfPlay(String url) {
    perform.invokeMethod('xfplay', {'url': url});
  }

}