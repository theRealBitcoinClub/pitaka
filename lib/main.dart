import 'views/app.dart';
import 'package:flutter/material.dart';
import 'utils/globals.dart';
import 'views/receive.dart';


void main() {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  ReceiveComponentState comp = new ReceiveComponentState();
  comp.getAccounts();

  runApp(new AppComponent());
}
