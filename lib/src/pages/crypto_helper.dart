
/*

import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoHelper {
  // Clave de 32 caracteres para AES-256
  static final key = encrypt.Key.fromUtf8(
    '32_caracteres_muy_seguras_para_AES_256!',
  );
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  // Cifrar texto
  static String encryptText(String plainText) {
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // Descifrar texto
  static String decryptText(String encryptedText) {
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}






*/ 