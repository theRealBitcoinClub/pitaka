import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_dialog/easy_dialog.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:overlay_support/overlay_support.dart';
import '../views/app.dart';
import '../utils/globals.dart' as globals;


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


onDialogClose() {
  // Not use
}

// Alert dialog for push notification
showPushNotificationDialog(context, message) {
  EasyDialog(
    title: Text(
      message['notification']['title'],
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      message['notification']['body'],
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}

// Alert dialog for error in sending email
showPublicKeyNotFoundDialog(context) {
  EasyDialog(
    title: Text(
      "Public Key Not Found!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The public key you've entered is not found. "
      "Please make sure that the public key is correct.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}

// Dialog for backing up private key
savePrivatePublicKeyDialog(context) async {
  String seedPhrase = await globals.storage.read(key: "seedPhrase");
  
  EasyDialog(
    cornerRadius: 10.0,
    fogOpacity: 0.5,
    width: 280,
    height: 440,
    contentPadding: EdgeInsets.only(top: 15.0),
    contentList: [
      Center(
        child: Text(
          "Backup your Seed Phrase!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        )
      ),
      SizedBox(height: 20.0,),
      GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: seedPhrase));
          showSimpleNotification(
            Text("Seed Phrase copied to clipboard."),
            background: Colors.red[600],
          );
        },
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            children: <Widget>[
              Divider(color: Colors.black,),
              Center(
                child: Text(
                  "$seedPhrase",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'RobotoMono',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(color: Colors.black,),
            ]
          )

        ),
      ),
      SizedBox(height: 20.0),
      Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Center(
          child: Text(
            "Write down or save this seed phrase somewhere safe as a backup. "
            "This is for recovering your account in case your phone gets damaged or lost. "
            "Tap the seed phrase text to copy to clipboard.",
            style: TextStyle(fontSize: 16.0,),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      SizedBox(height: 10.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);


}

// Dialog for identity submit success
showIdentitySubmitSuccesslDialog(context) {
  EasyDialog(
    title: Text(
      "Success!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "Please allow up to 1 business day for our team to review your ID submission. "
      "We'll update you on the status of your verification by email and on your account limits page.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}


// Alert dialog for invalid or wrong OTP code during mobile number registration
showInvalidOTPCodeDialog(context) {
  EasyDialog(
    title: Text(
      "Invalid Code!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The code you've entered is invalid. "
      "You can request another code by entering your mobile number again. "
      "Please make sure to enter a valid or correct code.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 195,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
              Application.router.navigateTo(context, "/onboarding/requestotpforretry");
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}


// Alert dialog for invalid or wrong OTP code during account restoration
showInvalidOTPCodeAcctResDialog(context) {
  EasyDialog(
    title: Text(
      "Invalid Code!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The code you've entered is invalid. "
      "You can request another code by entering your master key again. "
      "Please make sure to enter a valid or correct code.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 180,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}


// Alert dialog for error in sending email
showInvalidCodelDialog(context) {
  EasyDialog(
    title: Text(
      "Invalid Code!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The code you've entered is invalid. "
      "Please make sure to enter a valid or correct code.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}


// Alert dialog for sending failure
showSendingFailureDialog(context) {
  EasyDialog(
    title: Text(
      "Sending Failure!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "There was a problem in sending the funds. "
      "Please try again.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}

// Alert dialog for error in sending email
showErrorSendingEmailDialog(context) {
  EasyDialog(
    title: Text(
      "Error Sending Email!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The email address you entered is unreachable or not valid. "
      "Please make sure to enter a valid email address.",
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


// Alert dialog for duplicate TIN
showDuplicateTINDialog(context) {
  EasyDialog(
    title: Text(
      "Duplicate TIN!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The TIN is already registered. Please double check the number you entered",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
              // Use same mobile number after retry on duplicate email 
              //Application.router.navigateTo(context, "/onboarding/register/$mobileNumber");
            },
            child: Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
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


// Alert dialog for maximum retries of OTP request
showMaxRetriesReachedDialog(context) {
  EasyDialog(
    title: Text(
      "Max Retries Reached!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "You've reached the maximum retries. "
      "Please contact Paytaca for assistance and support.",
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
              _launchPaytacaURL();
              SystemNavigator.pop();
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