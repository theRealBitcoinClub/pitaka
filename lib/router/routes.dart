import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './handlers.dart';

class Routes {
  static String root = "/";

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root, handler: rootHandler);
  }
}
