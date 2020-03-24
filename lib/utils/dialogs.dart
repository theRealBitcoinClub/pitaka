  
import 'package:flutter/material.dart';
import 'package:easy_dialog/easy_dialog.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter/services.dart';
import '../views/app.dart';


// Function that will redirect to Google Play Store 
// to download the latest version of Paytaca app 
_launchURL() async {
  const url = 'https://play.google.com/store/apps/details?id=com.paytaca.app&hl=en';
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}

onDialogClose() {
  // Not use
}

// Alert dialog for duplicate email address
showDuplicateEmailDialog(context) {
  EasyDialog(
    title: Text(
      "Duplicate Email Address!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The email address is already registered. Please use other email address",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
              // Use same mobile number after retry on duplicate email 
              //Application.router.navigateTo(context, "/onboarding/register/$mobileNumber");
            },
            child: new Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}

// Alert dialog for duplicate mobile number
showDuplicateMobileNumberDialog(context) {
  EasyDialog(
    title: Text(
      "Duplicate Mobile Number!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The mobile number is already registered. Please use other mobile number",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
              Application.router.navigateTo(context, "/onboarding/request");
            },
            child: new Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}
  
// Alert dialog for outdated app version
showOutdatedAppVersionDialog(context) {
  EasyDialog(
    title: Text(
      "Outdated App Version!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The app version you're running is outdated. Update your app to continue using and enjoy the latest features.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              _launchURL();
              SystemNavigator.pop();
            },
            child: new Text("Ok",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),),
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              SystemNavigator.pop();
            },
            child: new Text("Cancel",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}

// Function that will redirect to Google Play Store 
// to download the latest version of Paytaca app 
_launchPaytacaURL() async {
  const url = 'https://www.paytaca.com/';
  if (await canLaunch(url)) {
    await launch(url, forceWebView: false);
  } else {
    throw 'Could not launch $url';
  }
}

showUnregisteredUdidDialog(context) {
  showDialog(
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: Text(
                "Unregistered Device ID!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            new SizedBox(
              height: 15.0,
            ),
            Container(
              child: Text(
                "Your phone might have been compromised! "
                "Please contact Paytaca for assistance and support.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            Container(
              child: new FlatButton(
                child: new Text(
                  "OK",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16.0,
                  ),
                ),
                onPressed: () {
                  _launchPaytacaURL();
                  SystemNavigator.pop();
                },
              )
            )
          ]
        )
      ),
    ),
  );
}

Future<void> proofOfPaymentSuccessDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('Success'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Proof of payment has been validated.')
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay!'),
            onPressed: () {
              Navigator.of(context).pop();
              Application.router.navigateTo(context, "/home");
            },
          ),
        ],
      );
    },
  );
}

Future<void> proofOfPaymentFailedDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Failure'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("The proof of payment you scanned is invalid.")
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay!'),
            onPressed: () {
              Navigator.of(context).pop();
              Application.router.navigateTo(context, "/receive");
            },
          ),
        ],
      );
    },
  );
}