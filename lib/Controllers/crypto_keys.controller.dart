import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class CryptoKeys {
  static final CryptoKeys _instance = CryptoKeys._internal();
  factory CryptoKeys() => _instance;

  late final Uint8List _encryptionKeyUint8List;
  Map<String, String> _cryptoKeyList={};

  Map<String, String> get cryptoKeyList => _cryptoKeyList;
  CryptoKeys._internal();

  Future<void> init() async {
    const secureStorage = FlutterSecureStorage();
    final encryptionKeyString = await secureStorage.read(key: 'key');
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'key',
        value: base64UrlEncode(key),
      );
    }
    final key = (await secureStorage.read(key: 'key'))!;
    _encryptionKeyUint8List = base64Url.decode(key);
    await _readValues();
  }

  Future<void> _readValues() async {
    var cryptoKeys = await Hive.openBox<String>('crypto_keys',
        encryptionCipher: HiveAesCipher(_encryptionKeyUint8List));

    _cryptoKeyList = cryptoKeys.toMap().map((key, value) => MapEntry(key.toString(), value));
    cryptoKeys.close();
    
  }

  Future<bool> add(String alias, String key) async {
    var cryptoKeys = await Hive.openBox<String>('crypto_keys',
        encryptionCipher: HiveAesCipher(_encryptionKeyUint8List));
    if(cryptoKeys.containsKey(alias)) {print('hello');return false;}
    cryptoKeys.put(alias, key);
    _cryptoKeyList[alias] = key;
    cryptoKeys.close();
    return true;
  }

  Future<void> delete(String alias) async {
    var cryptoKeys = await Hive.openBox<String>('crypto_keys',
        encryptionCipher: HiveAesCipher(_encryptionKeyUint8List));
    cryptoKeys.delete(alias);
    _cryptoKeyList.remove(alias);
    cryptoKeys.close();
  }
}
