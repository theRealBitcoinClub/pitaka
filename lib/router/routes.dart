import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './handlers.dart';

class Routes {
  static String root = "/";
  static String onboardingRequest = "/onboarding/request";
  static String onboardingVerify = "/onboarding/verify/:mobilenumber";
  static String onboardingRegister = "/onboarding/register/:mobilenumber";
  static String account = "/account";
  static String terms = "/terms";
  static String home = "/home";
  static String send = "/send";
  static String receive = "/receive";
  static String businessRegistration = "/registerbusiness";
  static String setBusinessAccount = '/setbusinessaccount';
  static String businessTools = "/businesstools";

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      print("ROUTE WAS NOT FOUND!");
    });
    router.define(root,
        handler: rootHandler, transitionType: TransitionType.fadeIn);
    router.define(onboardingRequest,
        handler: onboardingRequestHandler,
        transitionType: TransitionType.fadeIn);
    router.define(onboardingVerify,
        handler: onboardingVerifyHandler,
        transitionType: TransitionType.fadeIn);
    router.define(onboardingRegister,
        handler: onboardingRegisterHandler,
        transitionType: TransitionType.fadeIn);
    router.define(account,
        handler: accountHandler, transitionType: TransitionType.fadeIn);
    router.define(
        terms,
        handler: termsHandler,
        transitionType: TransitionType.fadeIn
    );
    router.define(
        home,
        handler: homeHandler,
        transitionType: TransitionType.fadeIn
    );
    router.define(
        send,
        handler: sendHandler,
        transitionType: TransitionType.fadeIn
    );
    router.define(
        receive,
        handler: receiveHandler,
        transitionType: TransitionType.fadeIn
    );
    router.define(businessRegistration,
        handler: businessRegistrationHandler,
        transitionType: TransitionType.fadeIn
    );
    router.define(businessTools,
        handler: businessToolsHandler,
        transitionType: TransitionType.fadeIn
    );
    router.define(setBusinessAccount,
        handler: setBusinessAccountHandler,
        transitionType: TransitionType.fadeIn
    );
  }
}
