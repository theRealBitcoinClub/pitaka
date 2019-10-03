import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/database_helper.dart';
import 'package:flutter/services.dart';

//const String baseUrl = 'https://lantaka-dev.paytaca.com';
const String baseUrl = 'https://b21efe95.ngrok.io';
const String phpAssetId = '3A8F594F-D736-4673-945C-5465E0209AF0';

int offlineTime;
int timeDiff;
bool _maxOfflineTime = false;
bool _online = false;
bool _syncing = false;
const String serverPublicKey = '7aeaa44510a950a9a4537faa2f40351dc4560d6d0d12abc0287dcffdd667d7a2';
bool get online => _online;
bool get syncing => _syncing;
bool get maxOfflineTime => _maxOfflineTime;
final Connectivity _connectivity = Connectivity();
ConnectivityResult result;
//StreamSubscription<ConnectivityResult> _connectivitySubscription = _connectivity.onConnectivityChanged.listen();

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

set maxOfflineTime(bool value) => _maxOfflineTime = value;


Future<bool> iniConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  final result = await InternetAddress.lookup('google.com');
  try {
    if (connectivityResult == ConnectivityResult.mobile && result.isNotEmpty && result[0].rawAddress.isNotEmpty ||
        connectivityResult == ConnectivityResult.wifi && result.isNotEmpty && result[0].rawAddress.isNotEmpty ) {
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
  iniConnection().then((status) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("online", status);
  });
}

class ConnectionStatusSingleton {
  //This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionStatusSingleton _singleton = new ConnectionStatusSingleton._internal();
  ConnectionStatusSingleton._internal();

  //This is what's used to retrieve the instance through the app
  static ConnectionStatusSingleton getInstance() => _singleton;

  //This tracks the current connection status
  bool hasConnection = false;

  //This is how we'll allow subscribing to connection changes
  StreamController connectionChangeController = new StreamController.broadcast();

  //flutter_connectivity
  final Connectivity _connectivity = Connectivity();

  //Hook into flutter_connectivity's Stream to listen for changes
  //And check the connection status out of the gate
  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream get connectionChange => connectionChangeController.stream;

  //A clean up method to close our StreamController
  //   Because this is meant to exist through the entire application life cycle this isn't
  //   really an issue
  void dispose() {
    connectionChangeController.close();
  }

  //flutter_connectivity's listener
  void _connectionChange(ConnectivityResult result) {
    checkConnection();
  }

  //The test to actually see if there is a connection
  Future<bool> checkConnection() async {
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch(_) {
      hasConnection = false;
    }

    //The connection status changed send out an update to all listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }

}