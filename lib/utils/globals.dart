import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/database_helper.dart';
import 'package:flutter/services.dart';

const String baseUrl = 'https://lantaka-dev.paytaca.com';
// const String baseUrl = 'https://6e8d7119.ngrok.io';
const String phpAssetId = '3A8F594F-D736-4673-945C-5465E0209AF0';



bool _online = false;
bool _syncing = false;
const String serverPublicKey = '7aeaa44510a950a9a4537faa2f40351dc4560d6d0d12abc0287dcffdd667d7a2';
bool get online => _online;
bool get syncing => _syncing;
final Connectivity _connectivity = Connectivity();
StreamSubscription<ConnectivityResult> _connectivitySubscription = _connectivity.onConnectivityChanged.listen(checkConnection);

set online(bool value) {
  _online = value;
  if(_online) {
    syncing = true;
    databaseHelper.synchToServer();
  } else {
    syncing = false;
  }
}

set syncing(bool value) => _syncing = value;
DatabaseHelper databaseHelper = DatabaseHelper();

final storage = new FlutterSecureStorage();

@override
void dispose() {
  _connectivitySubscription.cancel();
}

Future<void> initConnection() async{
  ConnectivityResult result;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    result = await _connectivity.checkConnectivity();
  } on PlatformException catch (e) {
    print(e.toString());
  }
  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  checkConnection();
}

Future<bool> checkConnection(ConnectivityResult result) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  try {
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      online = true;
    } else {
      online = false;
    }
  }on PlatformException catch (e) {
    print(e);
  }
return online;
}


void checkInternet () async {
  checkConnection().then((status) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("online", status);
  });
}