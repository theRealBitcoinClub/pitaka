import 'views/app.dart';
import 'utils/globals.dart';
import 'package:flutter/material.dart';


void main() {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  runApp(new AppComponent());
}
