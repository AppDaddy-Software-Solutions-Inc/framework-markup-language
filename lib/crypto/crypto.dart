// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:crypto/crypto.dart';
import 'package:fml/log/manager.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:fml/helpers/helpers.dart';

class Cryptography {
  static const String _hashkey = "YOUR_KEY_HERE";
  static const String _sharedkey = "YOUR_KEY_HERE";

  static String hash({String key = _hashkey, required String text}) {
    Hmac hmacSha256 = Hmac(sha256, utf8.encode(key));
    var digest = hmacSha256.convert(utf8.encode(text));
    String base64 = base64Encode(digest.bytes);
    return base64;
  }

  static String encrypt(
      {String? secretkey = _sharedkey,
      String? vector = _sharedkey,
      String? text}) {
    if (isNullOrEmpty(text)) return "";

    Uint8List plainText = Uint8List.fromList(utf8.encode(text!));
    Uint8List key = Uint8List.fromList(utf8.encode(secretkey!));
    Uint8List iv = Uint8List.fromList(utf8.encode(vector!));

    PaddedBlockCipher cipher =
        PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));
    cipher.init(
        true,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
            ParametersWithIV<KeyParameter>(KeyParameter(key), iv), null));
    Uint8List cipherText = cipher.process(plainText);

    Base64Encoder encoder = const Base64Encoder.urlSafe();
    return encoder.convert(cipherText);
  }

  static String? decrypt(
      {String? secretkey = _sharedkey,
      String? vector = _sharedkey,
      String? text}) {
    if (text == null) return null;

    String? decrypted;
    Uint8List encryptedText = base64Decode(text);
    Uint8List key = Uint8List.fromList(utf8.encode(secretkey!));
    Uint8List iv = Uint8List.fromList(utf8.encode(vector!));

    final CBCBlockCipher cbcCipher = CBCBlockCipher(AESEngine());
    final ParametersWithIV<KeyParameter> ivParams =
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv);

    final PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>,
            CipherParameters?> paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>,
            CipherParameters?>(ivParams, null);

    final PaddedBlockCipherImpl cipher =
        PaddedBlockCipherImpl(PKCS7Padding(), cbcCipher);
    cipher.init(false, paddingParams);

    try {
      Uint8List clearText = cipher.process(encryptedText);
      decrypted = String.fromCharCodes(clearText);
    } catch (e) {
      Log().exception(e);
    }
    return decrypted;
  }
}
