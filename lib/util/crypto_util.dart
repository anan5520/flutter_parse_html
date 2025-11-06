import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

/// 从 JS 中提取的 key / iv
const String jsKey = '22946bc50fd63164b79df55070a85a92';
const String jsIv = 'kaixin1234567890';

String _base64UrlToBase64(String input) {
  // 将 URL-safe Base64 转为标准 Base64，并补齐 '='
  String s = input.replaceAll('-', '+').replaceAll('_', '/');
  final mod = s.length % 4;
  if (mod == 2) s += '==';
  else if (mod == 3) s += '=';
  else if (mod != 0) {
    // mod == 1 是非法长度，但仍尝试补齐
    s += List.filled((4 - mod), '=').join();
  }
  return s;
}

/// 解密：JS 的 decrypt 接受的是 Base64（或 URL-safe Base64），采用 AES-CBC + PKCS7
String decryptFromJs(String base64OrUrlSafeBase64Cipher, {String key = jsKey, String iv = jsIv}) {
  final norm = _base64UrlToBase64(base64OrUrlSafeBase64Cipher);
  // 注意：JS 里的 CryptoJS.AES.decrypt 有时直接接受 base64 字符串，
  // 有时传入 {ciphertext: CryptoJS.enc.Base64.parse(...)}；这里统一使用 decrypt64。
  final k = encrypt.Key.fromUtf8(key); // 直接把字符串当 UTF-8 字节序列
  final ivObj = encrypt.IV.fromUtf8(iv);
  final encrypter = encrypt.Encrypter(
    encrypt.AES(k, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
  );

  // decrypt64 接受标准 base64（not url-safe）
  final plain = encrypter.decrypt64(norm, iv: ivObj);
  return plain;
}

/// decryptJsonBase64: 先做 base64 decode -> AES decrypt -> JSON.parse
Map<String, dynamic> decryptJsonBase64(String base64Text, {String key = jsKey, String iv = jsIv}) {
  // 根据 JS 里 decryptJsonBase64 实现：先把 URL-safe base64 -> normal base64 -> Base64.decode -> AES.decrypt on ciphertext
  // 有两种常见 JS 写法：
  // 1) decryptJsonBase64: (f) => { const n = AES.decrypt({ciphertext: CryptoJS.enc.Base64.parse(e(f))}, key,...); return JSON.parse(n.toString(Utf8)); }
  // 2) 或直接 decrypt(atob(f), key)
  // 我们优先尝试普通：先把 f -> normal base64 -> base64 decode -> treat as ciphertext string in JS form
  final norm = _base64UrlToBase64(base64Text);
  // 在 CryptoJS 的情形 1)，JS 会把 Base64.parse(e(f)) 作为 ciphertext，因此你可能需要把 norm 直接传给 decryptFromJs OR
  // 有时需要先做 utf8.decode(base64.decode(norm)) 再传入 decrypt (看具体实现)
  try {
    // 先尝试常见方式：把 norm 当作 base64 密文直接解密
    final decrypted = decryptFromJs(norm, key: key, iv: iv);
    final decoded = json.decode(decrypted);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'value': decoded};
  } catch (err) {
    // 退而求其次：先 base64 decode 得到 bytes -> interpret as utf8 string -> 再当成 base64Cipher 解密
    final bytes = base64.decode(norm);
    final asString = utf8.decode(bytes);
    final decrypted = decryptFromJs(asString, key: key, iv: iv);
    final decoded = json.decode(decrypted);
    return decoded;
  }
}
