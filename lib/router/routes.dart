import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './handlers.dart';

class Routes {
  static String root = "/";
  static String onboardingRequest = "/onboarding/request";
  static String onboardingVerify = "/onboarding/verify/:mobilenumber";
  static String requestOTP = "/requestotp/:mobilenumber";
  static String onboardingRegister = "/onboarding/register/:mobilenumber";
  static String account = "/account";
  static String terms = "/terms";
  static String home = "/home";
  static String send = "/send";
  static String authenticate = "/authenticate";
  static String receive = "/receive";
  static String businessRegistration = "/registerbusiness";
  static String setBusinessAccount = '/setbusinessaccount';
  static String businessTools = "/businesstools";
  static String proofOfPayment = "/proofOfPayment";
  static String businesses = "/businesses";
  static String addAccount = "/addAccount";
  static String settings = "/settings";
  static String addPinCode = "/addpincode";
  static String addPinCodeAcctRes = "/addpincodeacctres";
  static String checkPinCode = "/checkpincode";
  static String contactList = "/contactlist"; 
  static String sendContact = "/sendcontact";
  static String sendLink = "/sendlink";
  static String userProfile = "/userprofile";
  static String verificationLevels = "/verificationlevels";
  static String registerEmailForm = "/registeremailform";
  static String verifyEmailForm = "/verifyemailform";
  static String verifyIdentity = "/verifyidentity";

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      print("ROUTE WAS NOT FOUND!");
    });

    router.define(
      root,
      handler: rootHandler, 
      transitionType: TransitionType.fadeIn
    );

    router.define(
      onboardingRequest,
      handler: onboardingRequestHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      onboardingVerify,
      handler: onboardingVerifyHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      requestOTP,
      handler: requestOTPHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      onboardingRegister,
      handler: onboardingRegisterHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      account,
      handler: accountHandler, 
      transitionType: TransitionType.fadeIn
    );

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
      authenticate,
      handler: authenticateHandler,
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

    router.define(proofOfPayment,
      handler: proofOfPaymentAccountHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(businesses,
      handler: businessesHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(addAccount,
      handler: addAccountHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      settings,
      handler: settingsHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      addPinCode,
      handler: addPinCodeHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      addPinCodeAcctRes,
      handler: addPinCodeAcctResHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      checkPinCode,
      handler: checkPinCodeHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      contactList,
      handler: contactListHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      sendContact,
      handler: sendContactHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      sendLink,
      handler: sendLinkHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      userProfile,
      handler: userProfileHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      verificationLevels,
      handler: verificationLevelsHandler,
      transitionType: TransitionType.fadeIn
    );

    router.define(
      registerEmailForm,
      handler: registerEmailFormHandler,
      transitionType: TransitionType.fadeIn
    );
    
    router.define(
      verifyEmailForm,
      handler: verifyEmailFormHandler,
      transitionType: TransitionType.fadeIn
    );
    
    router.define(
      verifyIdentity,
      handler: verifyIdentityHandler,
      transitionType: TransitionType.fadeIn
    );
  }
}
