import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../views/landing.dart';
import '../views/onboarding/request.dart';
import '../views/onboarding/verify.dart';
import '../views/onboarding/register.dart';
import '../views/onboarding/account.dart';
import '../views/terms.dart';
import '../views/home.dart';
import '../views/send.dart';
import '../views/authenticate.dart';
import '../views/receive.dart';
import '../views/business/register.dart';
import '../views/business/tools.dart';
import '../views/business/linkAccount.dart';
import '../views/proofOfPayment.dart';
import '../views/business/businesses.dart';
import '../views/addAccount.dart';
import '../views/settings.dart';
import '../views/addPinCode.dart';
import '../views/checkPinCode.dart';
import '../views/contactList.dart';
import '../views/sendContact.dart';
import '../views/userProfile.dart';
import '../views/verificationLevels.dart';
import '../views/registerEmailForm.dart';


var rootHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new LandingComponent();
});

var onboardingRequestHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new RequestComponent();
});

var onboardingVerifyHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new VerifyComponent(mobileNumber: params["mobilenumber"][0]);
});

var onboardingRegisterHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new RegisterComponent(mobileNumber: params["mobilenumber"][0]);
});

var accountHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new AccountComponent();
});

var termsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new TermsComponent();
});

var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new HomeComponent();
});

var sendHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new SendComponent();
});

var authenticateHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new AuthenticateComponent();
});

var receiveHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new ReceiveComponent();
});

var businessRegistrationHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new BusinessRegistrationComponent();
});

var businessToolsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new BusinessToolsComponent();
});

var setBusinessAccountHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new SetBusinessAccountComponent();
});


var proofOfPaymentAccountHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new ProofOfPaymentComponent();
});

var businessesHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new BusinessesComponent();
});

var addAccountHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return new AddAccountComponent();
});

var settingsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new SettingsComponent();
});

var addPinCodeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new AddPincodeComponent();
});

var checkPinCodeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new CheckPincodeComponent();
});

var contactListHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new ContactListComponent();
});

var sendContactHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new SendContactComponent();
});

var userProfileHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new UserProfileComponent();
});

var verificationLevelsHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new VerificationLevelsComponent();
});

var registerEmailFormHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new RegisterEmailFormComponent();
});