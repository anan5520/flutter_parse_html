import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HiddenWebFetcher {
  static Future<String?> fetch(String url,
      {Duration timeout = const Duration(seconds: 25)}) async {
    final completer = Completer<String?>();
    HeadlessInAppWebView? headless;
    bool completed = false; // 防止重复完成

    print("🔍 准备加载: $url");

    headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(url),
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
              "AppleWebKit/537.36 (KHTML, like Gecko) "
              "Chrome/120.0.0.0 Safari/537.36",
        },
      ),
      onWebViewCreated: (controller) {
        print("✅ WebView 已创建");
      },
      onProgressChanged: (controller, progress) async {
        print("📶 加载进度: $progress%");
        if (progress == 100 && !completed) {
          completed = true;
          try {
            final html = await controller.evaluateJavascript(
                source: "document.documentElement.outerHTML;");
            completer.complete(html?.toString());
          } catch (e) {
            completer.completeError(e);
          } finally {
            Future.delayed(const Duration(seconds: 1), () {
              headless?.dispose();
            });
          }
        }
      },
      onLoadStart: (controller, uri) {
        print("🚀 开始加载: $uri");
      },
      onLoadStop: (controller, uri) async {
        print("✅ 加载完成: $uri");
        if (!completed) {
          completed = true;
          try {
            final html = await controller.evaluateJavascript(
                source: "document.documentElement.outerHTML;");
            completer.complete(html?.toString());
          } catch (e) {
            completer.completeError(e);
          } finally {
            Future.delayed(const Duration(seconds: 1), () {
              headless?.dispose();
            });
          }
        }
      },
      onLoadError: (controller, uri, code, message) {
        print("❌ 加载错误: $code, $message");
        if (!completed) completer.completeError(message);
        headless?.dispose();
      },
    );

    await headless.run();
    print("🧠 Headless WebView 已运行");

    return completer.future.timeout(timeout, onTimeout: () {
      print("⏰ 加载超时");
      headless?.dispose();
      throw TimeoutException("网页加载超时 ($timeout)");
    });
  }
}
