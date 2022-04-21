import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

import 'package:encrypt/encrypt.dart' as enc;

///
///aes加解密
///Date: 2019-05-23
///
class AesUtils {
  static const String _aeskey_en = 'dctv2952dctv2952dctv2952dctv2952';
  static const String _aeskey_de = 'dctv1688dctv1688';
  static const int _iv_size = 16;

  static String aesKey = "dctv2952dctv2952dctv2952dctv2952";
  static String aesIv = "dctv1688dctv1688";
  static var key = enc.Key.fromUtf8(aesKey);
  static var iv = enc.IV.fromUtf8(aesIv);
  static var encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

  /// enc lib
  /// aes256 encrypt
  static Uint8List encryptAES(text) {
    final encrypted = encrypter.encryptBytes(text, iv: iv);
    return encrypted.bytes;
  }

  /// enc lib
  /// aes256 decrypt
  static List<int> decryptAES(encData) {
    enc.Encrypted en = enc.Encrypted(encData);
    return encrypter.decryptBytes(en, iv: iv);
  }

  /// AES加密 128
  ///
  /// - Parameters:
  ///   - msg: 原始字串
  /// - Returns: String
  static String aes128Encrypt(String msg) {
    ///宣告key轉byte[]
    var raw = utf8.encode(_aeskey_en);
    var utf8Raw = Uint8List.fromList(raw);

    ///宣告iv長度轉byte[]
    var iv = Uint8List(_iv_size);

    ///宣告隨機數
    var random = Random.secure();

    ///宣告隨機數列長度為16
    var values = List<int>.generate(16, (i) => random.nextInt(256));

    ///轉成byte[]
    iv = Uint8List.fromList(values);

    ///宣告chiper方法及帶入key和iv
    CipherParameters params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(utf8Raw), iv), null);

    ///使用AES/CBC/PKCS7格式
    BlockCipher encryptionCipher = PaddedBlockCipher('AES/CBC/PKCS7');

    ///cipher初始化，true代表encrypt
    encryptionCipher.init(true, params);

    var rawMsg = utf8.encode(msg);
    var utf8Msg = Uint8List.fromList(rawMsg);

    ///原始字串轉byte[]後，由cipher執行壓碼
    Uint8List encrypted = encryptionCipher.process(utf8Msg);

    ///添加規則，規則為msg轉byte 和 vi隨機數轉byte，二筆加再一起
    var outBytes = Uint8List(_iv_size + encrypted.length);

    ///宣告空陣列去裝規則內容
    List<int> list = [];
    for (var i in encrypted) {
      list.add(i);
    }
    for (var i in iv) {
      list.add(i);
    }

    ///將陣列轉為byte[]
    outBytes = Uint8List.fromList(list);

    ///最後回傳base64字串
    return base64.encode(outBytes);
  }

  /// AES解密 128
  ///
  /// - Parameters:
  ///   - encrypted: 壓過碼的字串
  /// - Returns: String
  static String aes128Decrypt(String encrypted) {
    ///宣告key轉byte[]
    var raw = utf8.encode(_aeskey_de);
    var utf8Raw = Uint8List.fromList(raw);

    ///將壓碼字串作base64解碼
    var enctypted1 = base64Decode(encrypted);

    ///宣告iv長度轉byte[]
    var iv = Uint8List(_iv_size);

    ///宣告解密規則
    var msgBytes = Uint8List(enctypted1.length - _iv_size);

    ///將aes encrypt字串內容長度轉byte丟進msgBytes
    msgBytes = enctypted1.buffer.asUint8List(0, msgBytes.length);

    ///將aes encrypt字串內容長度取後iv長度丟進ivByte
    iv = Uint8List.fromList(enctypted1.skip(msgBytes.length).toList());

    ///宣告chiper方法及帶入key和iv
    CipherParameters params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(utf8Raw), iv), null);

    ///使用AES/CBC/PKCS7格式
    BlockCipher decryptionCipher = PaddedBlockCipher('AES/CBC/PKCS7');

    ///cipher初始化，false代表descrypt
    decryptionCipher.init(false, params);

    ///將msgBytes由cipher執行壓碼
    var cipherProcess = decryptionCipher.process(msgBytes);

    ///將結果轉回字串
    String decyptedResult = utf8.decode(cipherProcess);

    ///回傳明碼字串
    return decyptedResult;
  }
}
