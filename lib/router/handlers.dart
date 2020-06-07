import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../views/landing.dart';
import '../views/onboarding/request.dart';
import '../views/onboarding/requestOTPForRetry.dart';
import '../views/onboarding/verify.dart';
import '../views/onboarding/requestOTP.dart';
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
import '../views/addPinCodeAcctRes.dart';
import '../views/checkPinCode.dart';
import '../views/contactList.dart';
import '../views/sendContact.dart';
import '../views/sendLink.dart';
import '../views/userProfile.dart';
import '../views/verificationLevels.dart';
import '../views/registerEmailForm.dart';
import '../views/verifyEmailForm.dart';
import '../views/verifyIdentity.dart';


var rootHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return LandingComponent();
});

var onboardingRequestHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return RequestComponent();
});

var onboardingRequestOTPForRetryHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return RequestOTPForRetryComponent();
});

var onboardingVerifyHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return VerifyComponent(mobileNumber: params["mobilenumber"][0]);
});

var requestOTPHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return RequestOTPComponent(mobileNumber: params["mobilenumber"][0]);
});

var onboardingRegisterHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return RegisterComponent(mobileNumber: params["mobilenumber"][0]);
});

var accountHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AccountComponent();
});

var termsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return TermsComponent();
});

var homeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return HomeComponent();
});

var sendHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return SendComponent();
});

var authenticateHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AuthenticateComponent();
});

var receiveHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return ReceiveComponent();
});

var businessRegistrationHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return BusinessRegistrationComponent();
});

var businessToolsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return BusinessToolsComponent();
});

var setBusinessAccountHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return SetBusinessAccountComponent();
});


var proofOfPaymentAccountHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return ProofOfPaymentComponent();
});

var businessesHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return BusinessesComponent();
});

var addAccountHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AddAccountComponent();
});

var settingsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return SettingsComponent();
});

var addPinCodeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return AddPincodeComponent();
});

var addPinCodeAcctResHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return AddPincodeAcctResComponent();
});

var checkPinCodeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return CheckPincodeComponent();
});

var contactListHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return ContactListComponent();
});

var sendContactHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return SendContactComponent();
});

var sendLinkHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return SendLinkComponent();
});

var userProfileHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return UserProfileComponent();
});

var verificationLevelsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return VerificationLevelsComponent();
});

var registerEmailFormHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return RegisterEmailFormComponent();
  }
);

var verifyEmailFormHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return VerifyEmailFormComponent();
  }
);

var verifyIdentityHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return VerifyIdentityComponent();
  }
);