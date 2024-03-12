import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart' as pc;
class EncryptUtil {
  static const List<int> bytes = [8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8];

  //aes加密
  String aesEncode(String content) {
    try {
      final key = Key.fromBase64(base64Encode(bytes));
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(content, iv: IV.fromBase64(base64Encode(bytes)));
      return encrypted.base64;
    } catch (err) {
      print("aes encode error:$err");
      return content;
    }
  }

  //aes加密
  String aesEncode1(String content) {
    try {
      final key = Key.fromUtf8('wGzuseHaujl2UMao');
      final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
      final encrypted = encrypter.encrypt(content, iv: IV.fromSecureRandom(0));
      return encrypted.base64;
    } catch (err) {
      print("aes encode error:$err");
      return content;
    }
  }

  //aes解密
  dynamic aesDecode(dynamic base64Str) {
    try {
      final key = Key.fromBase16('66356439363564663735333336323730');
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      return base64Encode(encrypter.decryptBytes(Encrypted.fromBase64(base64Str), iv: IV.fromBase16('39376236303339346162633266626531')));
    } catch (err) {
      print("aes decode error:$err");
      return base64Str;
    }
  }

  //aes解密
  dynamic aesDecode1(dynamic base64Str) {
    try {
      // return decrypt(base64Str, Uint8List.fromList('wGzuseHaujl2UMao'.codeUnits), Uint8List.fromList('3452'.codeUnits));
      final key = Key.fromUtf8('wGzuseHaujl2UMao');
      final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
      return encrypter.decrypt64(base64Str,iv: IV.fromSecureRandom(0));
    } catch (err) {
      print("aes decode error:$err");
      return base64Str;
    }
  }

  String decrypt(String cipher, Uint8List key, Uint8List iv) {
    final encryptedText = encrypt.Encrypted.fromUtf8(cipher);
    final ctr = pc.CTRStreamCipher(pc.AESFastEngine())
      ..init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));
    Uint8List decrypted = ctr.process(encryptedText.bytes);
    String decodeOri = String.fromCharCodes(decrypted);
    String decodeStr = utf8.decode(decodeOri.codeUnits);
    print(decodeStr);

    return decodeStr;
  }
}