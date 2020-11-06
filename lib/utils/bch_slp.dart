import '../utils/globals.dart' as globals;
import 'package:bitbox/bitbox.dart' as Bitbox;
import "package:hex/hex.dart";
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


Future<String> generateSLPAddress() async {
  String seedPhrase = await globals.storage.read(key: "seedPhrase");
  Uint8List seed = Uint8List.fromList(utf8.encode(seedPhrase));
  final masterNode = Bitbox.HDNode.fromSeed(seed);
  final accountDerivationPath = "m/44'/0'/0'/0";
  final accountNode = masterNode.derivePath(accountDerivationPath);
  final childNode = accountNode.derive(0);

  String bchAddress = childNode.toCashAddress();
  await globals.storage.write(key: "bchAddress", value: bchAddress);

  String bchPrivateKey = childNode.keyPair.toWIF();
  await globals.storage.write(key: "bchPrivateKey", value: bchPrivateKey);

  return bchAddress;
}
