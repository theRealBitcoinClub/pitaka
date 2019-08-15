import 'views/app.dart';
import 'package:flutter/material.dart';
import 'utils/globals.dart';


void main() {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  runApp(new AppComponent());
}
