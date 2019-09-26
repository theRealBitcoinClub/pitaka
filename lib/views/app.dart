import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import '../router/routes.dart';
import '../utils/globals.dart' as globals;
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppComponent extends StatefulWidget {
  @override
  State createState() {
    return new AppComponentState();
  }
}

class Application {
  static Router router;
}

class AppComponentState extends State<AppComponent> with AfterLayoutMixin<AppComponent>{
  static bool debugMode = false;
  bool maxOfflineTime = globals.maxOfflineTime;
  bool online = globals.online;
  int offlineTime;
  
  AppComponentState() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    final app = new MaterialApp(
      title: 'Paytaca',
      debugShowCheckedModeBanner: debugMode,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      onGenerateRoute: Application.router.generator,
    );
    return app;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Call startTimer function, this will be called once at app startup
    startTimer();
    // At app startup check if offline and get timestamp 
    // Add delay to prevent false reading of globals.online default value
    Future.delayed(Duration(milliseconds: 500), () async {
      if (globals.online == false) {
        print("Hello");
        var prevTime = await _read();
        print(prevTime);
        if (prevTime == 0) {print(_read());
          offlineTime = new DateTime.now().millisecondsSinceEpoch;
          _save(offlineTime);
        } else {
          var currentTime = new DateTime.now().millisecondsSinceEpoch;
          // Convert milliseconds time difference to seconds
          var timeDiff = (currentTime - prevTime) / 1000;
          print("You've been offline for $timeDiff seconds");
        }
      } else {
        offlineTime = 0;
        _save(offlineTime);
      }
    });
  }

  // Timer for maximum offline timeoutTimer
  Timer _timer;
  int _start = 0;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
          //if (_start >= 21600 || online == true) {  // 6 hours
          if (globals.online == true) { // 1 minute
            timer.cancel();
            globals.maxOfflineTime = false;
          } else if (_start >= 60) {
            timer.cancel();
            globals.maxOfflineTime = true;
          } else {
            _start = _start + 1;
            print(_start);
            globals.maxOfflineTime = false;
          }
        }));
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'offlineTimeKey';
    final value = prefs.getInt(key) ?? 0;
    return value;
  }

  _save(val) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'offlineTimeKey';
    final value = val;
    prefs.setInt(key, value);
  }

}
