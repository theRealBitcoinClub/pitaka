import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../views/landing.dart';
import '../views/onboarding/verify.dart';
import '../views/onboarding/register.dart';
import '../views/account.dart';
import '../views/terms.dart';
import '../views/home.dart';
import '../views/send.dart';
import '../views/receive.dart';

var rootHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new LandingComponent();
});

var onboardingVerifyHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new VerifyComponent();
  });

var onboardingRegisterHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new RegisterComponent();
});

var accountHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new AccountComponent();
});

var termsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new TermsComponent();
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
