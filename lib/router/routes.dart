import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './handlers.dart';

class Routes {
  static String root = "/";
  static String onboardingVerify = "/onboarding-verify";
  static String onboardingRegister = "/onboarding-register";
  static String account = "/account";
  static String terms = "/terms";
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
    // router.define(onboardingVerify,
    //     handler: onboardingVerifyHandler, transitionType: TransitionType.fadeIn);
    router.define(onboardingRegister,
        handler: onboardingRegisterHandler, transitionType: TransitionType.fadeIn);
    router.define(account,
        handler: accountHandler, transitionType: TransitionType.fadeIn);
    router.define(terms,
        handler: termsHandler, transitionType: TransitionType.fadeIn);
    router.define(home,
        handler: homeHandler, transitionType: TransitionType.fadeIn);
    router.define(send,
        handler: sendHandler, transitionType: TransitionType.fadeIn);
    router.define(receive,
        handler: receiveHandler, transitionType: TransitionType.fadeIn);
  }
}
