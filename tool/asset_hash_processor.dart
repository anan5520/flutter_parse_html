import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  // 1. 定义关键路径
  final webAssetsDir = Directory('build/web/assets'); // 打包后的资源目录
  final assetManifestPath = 'build/web/assets/AssetManifest.json'; // 资源清单文件
  if (!webAssetsDir.existsSync() || !File(assetManifestPath).existsSync()) {
    print("错误：未找到 Web 打包资源，请先执行 flutter build web --release");
    return;
  }

  // 2. 读取原始 AssetManifest.json
  final manifestFile = File(assetManifestPath);
  final Map<String, dynamic> originalManifest =
  json.decode(manifestFile.readAsStringSync());

  // 3. 存储“原始资源路径 → 带 Hash 资源路径”的映射
  final Map<String, String> hashPathMap = {};

  // 4. 遍历所有资源，添加 Hash 并重命名
  for (final entry in originalManifest.entries) {
    final originalPath = entry.key; // 原始路径（如 images/cover0.jpg）
    final originalFullPath = '${webAssetsDir.path}/$originalPath';
    final originalFile = File(originalFullPath);

    if (!originalFile.existsSync()) {
      print("警告：资源 $originalFullPath 不存在，跳过处理");
      continue;
    }

    // 4.1 计算文件 MD5 Hash（取前8位，避免文件名过长）
    final fileBytes = originalFile.readAsBytesSync();
    final md5Hash = md5.convert(fileBytes).toString().substring(0, 8);

    // 4.2 构建带 Hash 的文件名（如 cover0.jpg → cover0.abc123.jpg）
    final pathSegments = originalPath.split('/');
    final fileName = pathSegments.last; // 文件名（如 cover0.jpg）
    final nameWithoutExt = fileName.split('.').first; // 无后缀名（如 cover0）
    final ext = fileName.split('.').length > 1
        ? '.${fileName.split('.').last}'
        : ''; // 后缀（如 .jpg）
    final hashedFileName = '$nameWithoutExt.$md5Hash$ext'; // 带 Hash 的文件名

    // 4.3 构建带 Hash 的完整路径
    final hashedPathSegments = [...pathSegments.sublist(0, pathSegments.length - 1), hashedFileName];
    final hashedPath = hashedPathSegments.join('/'); // 带 Hash 的相对路径（如 images/cover0.abc123.jpg）
    final hashedFullPath = '${webAssetsDir.path}/$hashedPath'; // 带 Hash 的完整路径

    // 4.4 重命名文件（覆盖原文件，或可改为复制避免风险）
    originalFile.renameSync(hashedFullPath);
    print("处理完成：$originalPath → $hashedPath");

    // 4.5 记录映射关系
    hashPathMap[originalPath] = hashedPath;
  }

  // 5. 生成新的 AssetManifest.json（替换为带 Hash 的路径）
  final Map<String, dynamic> newManifest = {};
  for (final entry in originalManifest.entries) {
    final originalPath = entry.key;
    if (hashPathMap.containsKey(originalPath)) {
      // 替换为带 Hash 的路径
      newManifest[originalPath] = [hashPathMap[originalPath]];
    } else {
      // 未处理的资源保持原路径
      newManifest[originalPath] = entry.value;
    }
  }

  // 6. 写入新的 AssetManifest.json
  manifestFile.writeAsStringSync(
    json.encode(newManifest, toEncodable: (obj) => obj),
    encoding: utf8,
  );
  print("\n✅ 所有资源 Hash 处理完成，新 AssetManifest.json 已生成");
}