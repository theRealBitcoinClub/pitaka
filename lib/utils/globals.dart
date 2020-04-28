import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/database_helper.dart';


// For dev server
const String baseUrl = 'https://lantaka-dev.paytaca.com';
const String phpAssetId = '3A8F594F-D736-4673-945C-5465E0209AF0';

// For local server, testing/debugging
// const String baseUrl = 'https://e7be2f67.ngrok.io';
// const String phpAssetId = 'C7F4D976-9204-47DC-B998-754C29B043C5';

// App version
const String appVersion = 'v0.2.0';

// Scanbot SDK license key
const SCANBOT_SDK_LICENSE_KEY =
  "eV1Zf7LUb4lYV7gKEx2akrpqgmGtiA" +
  "PSeoarA1NdoYZAqPnsRTLphoMkecn0" +
  "koVs2ij0qQjvJGVAPN3+BescgZ84X6" +
  "upjZuQBEbFpde0dc7Kht+0mNA6qYBX" +
  "7k+VQdsbFa8lXgeaa4k3oqLE0qq9zE" +
  "3JU/KWUASoLnPuGvWNqy1xllnuj6Bj" +
  "dRZv8gWlWAW3d/2KyL/rIh6etv7tAS" +
  "FhZQQg4Zhb/usWHC3PkrALKHjIlrQK" +
  "kXkPNeIx/tY8wSrRMHE942RxWgYlWl" +
  "vqlTsIR7v+LC4B/RzW1TMu+/DaKKJa" +
  "7tefAz6qxfEhGmzMP1APnY4m3NQ9Ea" +
  "/+EErqxOoDMw==\nU2NhbmJvdFNESw" +
  "pjb20ucGF5dGFjYS5hcHAKMTU5MDcx" +
  "MDM5OQo1OTAKMw==\n";

int offlineTime;
int timeDiff;
bool _maxOfflineTime = false;
bool _online = false;
bool _syncing = false;
ConnectivityResult result;
final storage = new FlutterSecureStorage();
const String serverPublicKey = '7aeaa44510a950a9a4537faa2f40351dc4560d6d0d12abc0287dcffdd667d7a2';

// Get global variables
bool get online => _online;
bool get syncing => _syncing;
bool get maxOfflineTime => _maxOfflineTime;

// Set global variables
set online(bool value) {
  _online = value;
  if (_online) {
    if (syncing == false) {
      databaseHelper.synchToServer();
    }
  } else {
    syncing = false;
  }
}

DatabaseHelper databaseHelper = DatabaseHelper();

set syncing(bool value) => _syncing = value;
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

void checkInternet() async {
  iniConnection().then((status) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("online", status);
  });
}

// Connection Status Notifier
class ConnectionStatusSingleton {
  // This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionStatusSingleton _singleton = new ConnectionStatusSingleton._internal();
  ConnectionStatusSingleton._internal();

  // This is what's used to retrieve the instance through the app
  static ConnectionStatusSingleton getInstance() => _singleton;

  // This tracks the current connection status
  bool hasConnection = false;

  // This is how we'll allow subscribing to connection changes
  StreamController connectionChangeController = new StreamController.broadcast();

  // Flutter_connectivity
  final Connectivity _connectivity = Connectivity();

  // Hook into flutter_connectivity's Stream to listen for changes
  // And check the connection status out of the gate
  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream get connectionChange => connectionChangeController.stream;

  // A clean up method to close our StreamController
  // Because this is meant to exist through the entire application life cycle this isn't
  // really an issue
  void dispose() {
    connectionChangeController.close();
  }

  // Flutter_connectivity's listener
  void _connectionChange(ConnectivityResult result) {
    checkConnection();
  }

  // The test to actually see if there is a connection
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

    // The connection status changed send out an update to all listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}

// Syncing Status Notifier
class SyncingStatusSingleton {
  // This creates the single instance by calling the `_internal` constructor specified below
  static final SyncingStatusSingleton _singleton = new SyncingStatusSingleton._internal();
  SyncingStatusSingleton._internal();

  // This is what's used to retrieve the instance through the app
  static SyncingStatusSingleton getInstance() => _singleton;

  // This tracks the current connection status
  bool isSyncing = false;

  // This is how we'll allow subscribing to connection changes
  StreamController syncingChangeController = new StreamController.broadcast();

  void initialize() {
    checkSyncing();
  }

  Stream get syncingChange => syncingChangeController.stream;

  // A clean up method to close our StreamController
  // Because this is meant to exist through the entire application life cycle this isn't
  // really an issue
  void dispose() {
    syncingChangeController.close();
  }

  Future<bool> checkSyncing() async {
    bool notSyncing = isSyncing;

    if (syncing) {
      isSyncing = true;
    }
    else {
      isSyncing = false;
    }

    if (notSyncing != isSyncing) {
      syncingChangeController.add(isSyncing);
    }

    return isSyncing;
  }  
}