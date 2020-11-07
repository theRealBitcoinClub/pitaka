import '../utils/globals.dart' as globals;
import 'package:bitbox/bitbox.dart' as Bitbox;
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:slp_mdm/slp_mdm.dart';


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
  print("########## BCH Private Key: " + bchPrivateKey);
  print("########## BCH Address: " + bchAddress);
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

  print("########## BCH Private Key: " + spicePrivateKey);
  print("########## BCH Address: " + spiceAddress);
  globals.storage.write(key: "spicePrivateKey", value: spicePrivateKey);

  return spiceAddress;
}


void sendBCH() async {
  print("\n--------------- SEND BCH TRANSACTION ---------------\n");
  final private_key = "KzkuseSDMbf6vVWbTB9J8Exre3YW8pQwvbBYzYcekpJubZMY44Vd";
  final key_pair = Bitbox.ECPair.fromWIF(private_key);
  final senderAddress = Bitbox.Address.toCashAddress(key_pair.address);
  print("SENDER: " + senderAddress);

  final builder = Bitbox.Bitbox.transactionBuilder();

  final signatures = <Map>[];
  int totalBalance = 0;

  // Get UTXOs
  final utxos = await Bitbox.Address.utxo(key_pair.address) as List<Bitbox.Utxo>;
  print(utxos);

  utxos.forEach((Bitbox.Utxo utxo) {
    // add the utxo as an input for the transaction
    builder.addInput(utxo.txid, utxo.vout);

    // add a signature to the list to be used later
    signatures.add({
      "vin": signatures.length,
      "key_pair": key_pair,
      "original_amount": utxo.satoshis
    });

    totalBalance += utxo.satoshis;
  });

  print("BALANCE: " + totalBalance.toString());

  // set an address to send funds to
  final recipientAddress = "bitcoincash:qq7ethn4w80hdppv0nw302546tq3c8dqfg8l0cren6";
  int sendAmount = 10000;

  print("RECIPIENT: " + recipientAddress);
  print("AMOUNT: " + sendAmount.toString());

  // calculate the fee based on number of inputs and outputs
  final fee = Bitbox.BitcoinCash.getByteCount(signatures.length, 2);
  print(signatures.length);
  int sendAmountPlusFee = sendAmount + fee;

  // if there is enough balance, create a spending transaction
  if (totalBalance > sendAmountPlusFee && recipientAddress != "") {
    // add the output for the recipient
    builder.addOutput(recipientAddress, sendAmount);

    // add the output for the change
    int changeAmount = totalBalance - sendAmountPlusFee;
    print('FEE: ' + fee.toString());
    print('CHANGE: ' + changeAmount.toString());
    builder.addOutput(senderAddress, changeAmount);

    // sign all inputs
    signatures.forEach((signature) {
      builder.sign(signature["vin"], signature["key_pair"], 
	    signature["original_amount"]);
    });

    // build the transaction
    final tx = builder.build();
    print("TXID: " + tx.getId());
    print("TXHEX:\n\n" + tx.toHex() + "\n");
    // // broadcast the transaction
    // final txid = await Bitbox.RawTransactions.sendRawTransaction(tx.toHex());

    // Yatta!
    //print("Transaction broadcasted: $txid");
  } else if (totalBalance > sendAmountPlusFee) {
    print("Enter an output address to test send transaction");
  } else if (totalBalance < sendAmountPlusFee) {
    print("You do not have enough balance to perform this transaction");
  }
}

void sendSLP() async {
  print("\n--------------- SEND SLP TRANSACTION ---------------\n");
  final private_key = "KxCPnWBYh6wrUCd3ZimPvBwECwxcf8iqGnrAiS1DqXMQCeFr6LTf";
  final key_pair = Bitbox.ECPair.fromWIF(private_key);
  final senderAddress = Bitbox.Address.toCashAddress(key_pair.address);
  print("SENDER: " + senderAddress);

  final tokenId = hex.decode("4de69e374a8ed21cbddd47f2338cc0f479dc58daa2bbe11cd604ca488eca0ddf");
  int tokenBalance = 1000;
  
  final builder = Bitbox.Bitbox.transactionBuilder();

  final signatures = <Map>[];
  int bchBalance = 0;

  // Get UTXOs
  final utxos = await Bitbox.Address.utxo(key_pair.address) as List<Bitbox.Utxo>;
  print(utxos);

  utxos.forEach((Bitbox.Utxo utxo) {
    // add the utxo as an input for the transaction
    builder.addInput(utxo.txid, utxo.vout);

    // add a signature to the list to be used later
    signatures.add({
      "vin": signatures.length,
      "key_pair": key_pair,
      "original_amount": utxo.satoshis
    });

    bchBalance += utxo.satoshis;
  });

  print("BCH BALANCE: " + bchBalance.toString());

  // set an address to send funds to
  final recipientAddress = "bitcoincash:qq7ethn4w80hdppv0nw302546tq3c8dqfg8l0cren6";
  int sendAmount = 200;

  print("RECIPIENT: " + recipientAddress);
  print("AMOUNT: " + sendAmount.toString());

  // generate SLP OP_RETURN data
  int slpChange = tokenBalance - sendAmount;
  var slpSendMsg = Send(tokenId, [BigInt.from(sendAmount), BigInt.from(slpChange)]);
  var slpSendData = Uint8List.fromList(slpSendMsg);

  // calculate the fee based on number of inputs and outputs
  final fee = Bitbox.BitcoinCash.getByteCount(signatures.length, 4) + slpSendData.length;

  // if there is enough balance, create a spending transaction
  if (bchBalance > fee && recipientAddress != "") {

    // add output for the SLP SEND transaction data
    builder.addOutput(slpSendData, 0);

    int slpDust = 546;

    // add the output for the recipient of SLP token
    builder.addOutput(recipientAddress, slpDust);

    // add the output for the SLP token change
    builder.addOutput(senderAddress, slpDust);

    // add the output for the change
    int changeAmount = bchBalance - fee - (slpDust * 2);
    print('FEE: ' + fee.toString());
    print('CHANGE: ' + changeAmount.toString());
    builder.addOutput(senderAddress, changeAmount);

    // sign all inputs
    signatures.forEach((signature) {
      builder.sign(signature["vin"], signature["key_pair"], 
	    signature["original_amount"]);
    });

    // build the transaction
    final tx = builder.build();
    print("TXID: " + tx.getId());
    print("TXHEX:\n\n" + tx.toHex() + "\n");

  } else if (bchBalance > fee) {
    print("Enter an output address to test send transaction");
  } else if (bchBalance < fee) {
    print("You do not have enough balance to perform this transaction");
  }
}

// void main() {
//   // sendBCH();
//   sendSLP();
// }
