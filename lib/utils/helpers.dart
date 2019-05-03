import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'dart:convert' show utf8;
import 'dart:async';

String generateTransactionHash(Map txn) {
  List keys = txn.keys.toList();
  keys.sort();
  List<String> kvPairs = [];
  for (var i = 0; i < keys.length; i++) {
    String kvPair = keys[i] + ':' + txn[keys[i]].toString();
    kvPairs.add(kvPair);
  }
  String txnConcat = kvPairs.join(";");
  List<int> bytes = utf8.encode(txnConcat);
  String txnHash = sha256.convert(bytes).toString();
  return txnHash;
}

Future<String> signTransaction(String txnHash, String privateKey) async {
  var privateKeyBytes = HEX.decode(privateKey);
  final signature = await CryptoSign.sign(txnHash, privateKeyBytes);
  
  return HEX.encode(signature);
}
