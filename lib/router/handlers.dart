import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../views/landing.dart';
import '../views/register.dart';
import '../views/home.dart';
import '../views/send.dart';
import '../views/receive.dart';

var rootHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new LandingComponent();
});

var registerHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new RegisterComponent();
});

var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new HomeComponent();
});

var sendHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new SendComponent();
});

var receiveHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new ReceiveComponent();
});
