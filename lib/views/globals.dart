import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/globals.dart' as globals;
import '../views/home.dart';

List<Widget> netWorkIndentifier = [];




Future<SharedPreferences> getPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance().then((resp){
    return resp;
  });
  return prefs;
}

void checkInternet () {
  getPrefs().then((prefs) {
    prefs.setBool("online", true);
  });
}

void checker (dynamic parent) {
  getPrefs().then((prefs){
    List<Widget> arr = [];
    if (prefs.getBool("online") == true) {
      arr.add(
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            child: new Icon(Icons.wifi),
            onTap: (){
              prefs.setBool("online", false);
            }
          ) 
        )
      );
    } else {
      arr.add(
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(child: new Icon(Icons.signal_wifi_off), onTap: () {
            prefs.setBool("online", true);
            netWorkIndentifier.clear();
              netWorkIndentifier.add(
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    child: new Icon(Icons.wifi),
                    onTap: (){
                      prefs.setBool("online", false);
                    }
                  ) 
                )
              );
          },) 
        )
      );
    }
    netWorkIndentifier = arr;  
  });
}
