import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import '../router/routes.dart';
import '../utils/globals.dart' as globals;
import 'package:after_layout/after_layout.dart';

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
    // Calling the same function "after layout" to resolve the issue.
    startTimer();
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
          if (_start >= 60 || online == true) { // 1 minute
            timer.cancel();
            globals.maxOfflineTime = true;
          } else {
            _start = _start + 1;
            print(_start);
            globals.maxOfflineTime = false;
          }
        }));
  }

}
