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
  int timeDiff = globals.timeDiff;
  int offlineTime = globals.offlineTime;
  
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
    // startTimer();

    // At app startup check if offline and get timestamp 
    // Add delay to prevent false reading of globals.online default value
    Future.delayed(Duration(milliseconds: 500), () async {
      if (globals.online == false) {
        // Read the previous value of offlineTime
        var prevTime = await _read();
        print("It's offline, offlineTime is: $prevTime - from 'app.dart'");

        if (prevTime == 0) {
          globals.offlineTime = new DateTime.now().millisecondsSinceEpoch;
          _save(globals.offlineTime);
          var val = await _read();
          print("It's offline, offlineTime set to $val - from 'app.dart'");
        } else {
          var currentTime = new DateTime.now().millisecondsSinceEpoch;
          // Convert milliseconds time difference to seconds
          globals.timeDiff = ((currentTime - prevTime) / 1000).round();
          print("You've been offline for" + " " + globals.timeDiff.toString() + " " + "seconds");

          if (globals.timeDiff >= 21600) {
            globals.maxOfflineTime = true;
          } else {
            startTimer();
          }
        }
      } else {
        // Set and save offlineTime value to zero when online
        globals.offlineTime = 0;
        _save(globals.offlineTime);
        var val = await _read();
        print("It's online, offlineTime set to $val - from 'app.dart'");
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
          if (globals.online == true) {
            timer.cancel();
            globals.maxOfflineTime = false;
          } else if (_start >= 21600 - globals.timeDiff) { // (60) 1 minute, change to 21600 for 6 hours
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
