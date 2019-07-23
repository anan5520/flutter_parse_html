# flutter_parse_html

从头开始记录flutter的学习 <br>
主要内容：<br>
1、flutter 安装环境配置以及过程中遇到的坑<br>
2、flutter 一些基本控件的使用 <br>
3、flutter mvp模式<br>
4、google 粑粑的 provider 使用<br>
5、flutter 数据库使用<br>
6、学习中<br>

## flutter 安装
安装环境 macOS<br>
开发工具 android studio<br>
按照 flutter 中文网的步骤 一步一步来的 https://flutterchina.club/setup-macos/<br>
中间可能有的下载缓慢 多等一下 最后运行flutter doctor 检查安装
### android 运行
我先试的android端安装 很顺利 android studio直接安装dart 、flutter插件 运行即可<br>
### ios 运行
在配置ios环境时运行brew install --HEAD libimobiledevice 报错:<br>
configure: error: Package requirements (libusbmuxd >= 1.1.0) were not met:<br>
Requested 'libusbmuxd >= 1.1.0' but version of libusbmuxd is 1.0.10<br>

Consider adjusting the PKG_CONFIG_PATH environment variable if you<br>
installed software in a non-standard prefix.<br>

Alternatively, you may set the environment variables libusbmuxd_CFLAGS<br>
and libusbmuxd_LIBS to avoid the need to call pkg-config.<br>
See the pkg-config man page for more details.<br>
READ THIS: https://docs.brew.sh/Troubleshooting<br>
需要运行brew unlink usbmuxd & brew install --HEAD usbmuxd而不是libusbmuxd<br>
上面配置完毕 android studio 打开flutter项目 连接上真机或者打开ios模拟器 在设备栏会看到设备连接<br>
在运行项目之前 [要在xcode中配置账号 证书](https://flutterchina.club/ios-release/) ,设置完毕点击studio中运行按钮或者Terminal中输入flutter run 即可
