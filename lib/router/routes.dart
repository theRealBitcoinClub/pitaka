import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './handlers.dart';

class Routes {
  static String root = "/";
  static String register = "/register";
  static String home = "/home";
  static String send = "/send";
  static String receive = "/receive";

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root,
        handler: rootHandler, transitionType: TransitionType.fadeIn);
    router.define(register,
        handler: registerHandler, transitionType: TransitionType.fadeIn);
    router.define(home,
        handler: homeHandler, transitionType: TransitionType.fadeIn);
    router.define(send,
        handler: sendHandler, transitionType: TransitionType.fadeIn);
    router.define(receive,
        handler: receiveHandler, transitionType: TransitionType.fadeIn);
  }
}
