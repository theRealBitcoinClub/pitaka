import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';


bool _online = false;
bool get online => _online;
set online(bool value) => _online = value;

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


