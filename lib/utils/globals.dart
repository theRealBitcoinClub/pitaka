import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

 // const String baseUrl = 'https://lantaka-dev.paytaca.com';
const String baseUrl = 'https://85d9bb64.ngrok.io';
const String phpAssetId = '';
bool _online = false;
const String serverPublicKey = '7aeaa44510a950a9a4537faa2f40351dc4560d6d0d12abc0287dcffdd667d7a2';
bool get online => _online;
set online(bool value) => _online = value;
final storage = new FlutterSecureStorage();

Future<bool> checkConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    online = true;
  } else {
    online = false;
  }
  return online;
}

void checkInternet () async {
  checkConnection().then((status) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("online", status);
  });
}


