import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';



bool _online = false;
bool get online => _online;
set online(bool value) => _online = value;

Future<SharedPreferences> getPrefs() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    online = true;
  } else {
    online = false;
  }
  SharedPreferences prefs = await SharedPreferences.getInstance().then((resp){
    return resp;
  });
  return prefs;
}

void triggerInternet(status) {
  print('Internet is turning $status'); 
}

void checkInternet () {
  getPrefs().then((prefs) {
    prefs.setBool("online", true);
  });
}


