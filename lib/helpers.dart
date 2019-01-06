  import 'package:flutter_sodium/flutter_sodium.dart';
  import "package:hex/hex.dart";
  
  Future<String> signTransaction(String txnHash, String privateKey) async {
    var privateKeyBytes = HEX.decode(privateKey);
    final signature = await CryptoSign.sign(txnHash, privateKeyBytes);
    return HEX.encode(signature);
  }
  