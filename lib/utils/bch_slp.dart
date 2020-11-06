import '../utils/globals.dart' as globals;
import 'package:bitbox/bitbox.dart' as Bitbox;
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';


Future<String> generateBchAddress() async {
  String seedPhrase = await globals.storage.read(key: "seedPhrase");
  Uint8List seed = Uint8List.fromList(utf8.encode(seedPhrase));
  final masterNode = Bitbox.HDNode.fromSeed(seed);
  final accountDerivationPath = "m/44'/0'/0'/0";
  final accountNode = masterNode.derivePath(accountDerivationPath);
  final childNode = accountNode.derive(0);

  String bchAddress = childNode.toCashAddress();
  globals.storage.write(key: "bchAddress", value: bchAddress);

  String bchPrivateKey = childNode.keyPair.toWIF();
  globals.storage.write(key: "bchPrivateKey", value: bchPrivateKey);

  return bchAddress;
}


Future<String> generateSpiceAddress() async {
  String seedPhrase = await globals.storage.read(key: "seedPhrase");
  Uint8List seed = Uint8List.fromList(utf8.encode(seedPhrase));
  final masterNode = Bitbox.HDNode.fromSeed(seed);
  final accountDerivationPath = "m/44'/0'/0'/0";
  final accountNode = masterNode.derivePath(accountDerivationPath);
  final childNode = accountNode.derive(1);

  String bchAddress = childNode.toCashAddress();
  Response<Map> response;
  Dio dio = new Dio();
  final url = "https://rest.bitcoin.com/v2/slp/convert/" + bchAddress;
  response = await dio.get(url);
  Map data = response.data;
  String spiceAddress = data['slpAddress'];

  String spicePrivateKey = childNode.keyPair.toWIF();
  globals.storage.write(key: "spicePrivateKey", value: spicePrivateKey);

  return spiceAddress;
}
